## Export Consul token environment variable

The Consul datacenter is configured to have ACL enabled so you will need a token
to perform operations.

During the deployment we saved the token into a configuration file `consul_env.conf`

`chmod +x provision_base.sh`{{execute T1}}

`./provision_base.sh`{{execute T1}}

## Install CTS

`curl -s https://releases.hashicorp.com/consul-terraform-sync/0.1.0-techpreview2/consul-terraform-sync_0.1.0-techpreview2_linux_amd64.zip -o consul-terraform-sync.zip`{{execute T1}}

`unzip consul-terraform-sync.zip`{{execute T1}}

`mv consul-terraform-sync /usr/local/bin/consul-terraform-sync`{{execute T1}}

`consul-terraform-sync -h`{{execute T1}}

## Configure CTS

## Start CTS

`consul-terraform-sync -config-file cts-config.hcl -inspect true`{{execute T1}}

`consul-terraform-sync -config-file cts-config.hcl -once`{{execute T1}}

`consul-terraform-sync -config-file cts-config.hcl`{{execute T1}}

## Check Files

## Change registration

`docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_HTTP_TOKEN}" \
  api sh -c "consul services register /assets/svc-api-tag.hcl"`{{execute T1}}

