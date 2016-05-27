require 'uri'

include Logging.globally(:log)

class AwsMetadata
  def initialize
    @base_url = Settings.aws.metadata.base_url
  end

  def hostname
    uri = URI::join(base_url, 'local-hostname')

    log.info "finding EC2 hostname: #{uri.to_s}"
    response = HTTParty.get(uri)
    hostname = response.body

    /^([^\.]+)\..*$/.match(hostname)[1]
  end

  def public_ip
    uri = URI::join(base_url, 'public-ipv4')

    log.info "finding EC2 public IP: #{uri.to_s}"
    response = HTTParty.get(uri)
    ip = response.body

    fail "invalid IP #{ip}" unless /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(ip)
    ip
  end

  private

  attr_reader :base_url
end
