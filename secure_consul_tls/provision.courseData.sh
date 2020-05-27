cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

log() {
  echo $(date) - ${1}
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

log Install Consul locally

CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
APP_VERSION=$(curl -s "${CHECKPOINT_URL}"/consul | jq .current_version | tr -d '"')

curl -s https://releases.hashicorp.com/consul/${APP_VERSION}/consul_${APP_VERSION}_linux_amd64.zip

unzip consul_${APP_VERSION}_linux_amd64.zip 
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

finish

EOFSRSLY

chmod +x /tmp/provision.sh
