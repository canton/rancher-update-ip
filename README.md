# rancher-update-ip
Periodically retrieve public IP from EC2 metadata and update DNS records.

EC2 Instance Metadata
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html#instancedata-data-retrieval

Rancher host label `io.rancher.host.external_dns_ip`
http://docs.rancher.com/rancher/latest/en/rancher-services/dns-service/#using-a-specific-ip-for-external-dns

## Required Environment Variables
- `RANCHER_URL` = Rancher Server URL
- `RANCHER_KEY` = Environment API Access Key
- `RANCHER_SECRET` = Environment API Key Secret
- `RANCHER_DNS_SERVICE` = Service name of External DNS Service
- `PERIOD` = default is 10 minutes (e.g. '10m')
- `RAYGUN_APIKEY` = Raygun API Key
