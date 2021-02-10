

## Check Environment

`chmod +x provision_base.sh`{{execute T1}}

`./provision_base.sh`{{execute T1}}

## Install CTS

`curl -s https://releases.hashicorp.com/consul-terraform-sync/0.1.0-techpreview2/consul-terraform-sync_0.1.0-techpreview2_linux_amd64.zip -o consul-terraform-sync.zip`{{execute T1}}

`unzip consul-terraform-sync.zip`{{execute T1}}

`mv consul-terraform-sync /usr/local/bin/consul-terraform-sync`{{execute T1}}

`consul-terraform-sync -h`{{execute T1}}

## Configure CTS

## Start CTS

## Check Files

