cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

log() {
  echo "\u001b[1m$(date) - ${1}\u001b[m"
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

log "Installing Helm 3.2.1"

pushd /tmp
curl -s https://get.helm.sh/helm-v3.2.1-linux-amd64.tar.gz -o helm-v3.2.1-linux-amd64.tar.gz
tar xzf helm-v3.2.1-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/bin/

# log "Generating port forwarding"
# log " - Consul will be accessible on port 8080 after deploy"
# socat tcp-listen:8080,reuseaddr,fork tcp:localhost:80
# log " - Web will be accessible on port 9090 after deploy"
# socat tcp-listen:8080,reuseaddr,fork tcp:localhost:80

finish

EOFSRSLY

chmod +x /tmp/provision.sh
