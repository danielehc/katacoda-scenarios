cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

# Close STDERR FD
exec 2<&-

# Open STERR as $LOG_FILE file for read and write.
exec 2<>/tmp/provision.log

log() {
  echo $(date) - ${1}
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


pushd ~

log "Starting Kubernetes...this might take up to 5 minutes."

minikube start --wait=true

log "Installing Consul service mesh."

helm repo add hashicorp https://helm.releases.hashicorp.com

helm install -f ~/consul-values.yml hashicorp hashicorp/consul

sleep 30

export IP_ADDR=$(hostname -I | awk '{print $1}')

kubectl port-forward service/hashicorp-consul-ui 80:80 --address ${IP_ADDR} &

finish

EOFSRSLY

chmod +x /tmp/provision.sh
