require 'uri'
require 'json'

include Logging.globally(:log)

class RancherClient
  def initialize
    @rancher_url = Settings.rancher.url
    @rancher_key = Settings.rancher.key
    @rancher_secret = Settings.rancher.secret
    @dns_service = Settings.rancher.dns_service
  end

  def update_public_ip(hostname, public_ip)
    log.info "starting to update #{hostname} to #{public_ip}"

    host = hosts_json['data'].find do |host_json|
      host_json['hostname'] == hostname
    end

    fail "cannot find host #{hostname}" if host.nil?

    url = host['links']['self']
    update_url = host['actions']['update']
    host_labels = host['labels']

    if public_ip == host_labels['io.rancher.host.external_dns_ip']
      log.info "exiting since public IP is not changed"
      return
    end

    host_labels['io.rancher.host.external_dns_ip'] = public_ip

    log.info "updating #{hostname} with #{public_ip}: #{url}"
    response = HTTParty.put(url,
      body: { labels: host_labels }.to_json,
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'},
      basic_auth: auth
    )
    body = JSON.parse(response.body)
    new_labels = body['labels']
    log.info "result: #{new_labels.to_s}"
    new_labels
  end

  def update_dns
    service = service_json

    containers_url = service['links']['instances']

    log.info "finding containers of #{dns_service}: #{containers_url}"
    containers = JSON.parse HTTParty.get(containers_url, basic_auth: auth).body

    containers['data'].each do |container|
      restart_url = container['actions']['restart']

      if restart_url
        log.info "restarting container #{container['id']}: #{restart_url}"
        HTTParty.post(restart_url, basic_auth: auth)
      else
        log.info "container #{container['id']} is now #{container['state']}"
      end
    end
    true
  end

  private
  attr_reader :rancher_url, :rancher_key, :rancher_secret, :dns_service

  def auth
    {username: rancher_key, password: rancher_secret}
  end

  def root_json
    @root_json ||= begin
      uri = URI::join(rancher_url, '/v1/projects')

      log.info "finding rancher root: #{uri.to_s}"
      response = HTTParty.get(uri, basic_auth: auth)
      JSON.parse(response.body)
    end
  end

  def hosts_json
    @hosts_json ||= begin
      url = root_json['data'][0]['links']['hosts']

      log.info "finding rancher hosts #{url}"
      response = HTTParty.get(url, basic_auth: auth)
      JSON.parse(response.body)
    end
  end

  def service_json
    @service_json ||= begin
      url = root_json['data'][0]['links']['services']
      uri = URI::parse(url)
      uri.query = URI.encode_www_form([['name', dns_service]])

      log.info "finding rancher service #{dns_service}: #{uri.to_s}"
      response = HTTParty.get(uri, basic_auth: auth)
      result = JSON.parse(response.body)
      services = result['data']

      if services.count != 1
        services.each { |s| info.log "found service #{s['id']}" }
        fail "cannot find DNS service #{dns_service}"
      end
      services[0]
    end
  end

end
