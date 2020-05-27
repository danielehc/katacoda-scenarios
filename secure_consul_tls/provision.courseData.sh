cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

log() {
  echo $(date) - ${1}
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

log "Install prerequisites"

apt-get install -y unzip curl jq net-tools dnsutils psmisc

log "Install Consul locally"


APP_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq .current_version | tr -d '"')

log Found Consul ${APP_VERSION}

curl -s https://releases.hashicorp.com/consul/${APP_VERSION}/consul_${APP_VERSION}_linux_amd64.zip -o consul_${APP_VERSION}_linux_amd64.zip

unzip consul_${APP_VERSION}_linux_amd64.zip 
chmod +x consul
mv consul /usr/local/bin/consul

finish

EOFSRSLY

chmod +x /tmp/provision.sh
