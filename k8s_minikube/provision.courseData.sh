cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

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

# pushd ~

log "Adding consul user"

useradd consul --create-home -G docker -s /bin/bash

cp /root/dc1-values.yml /home/consul
cp /root/dc2-values.yml /home/consul

chown consul: /home/consul/*.yml

log "Starting first Kubernetes cluster...this might take up to 5 minutes."


runuser -l consul -c "minikube start --vm-driver=docker -p dc1 -v 8 --memory 1024"

log "Starting second Kubernetes cluster...this might take up to 5 minutes."

runuser -l consul -c "minikube start --vm-driver=docker -p dc2 -v 8 --memory 1024"

# minikube start --wait=true

# log "Installing Consul service mesh."

# helm repo add hashicorp https://helm.releases.hashicorp.com

# helm install -f ~/consul-values.yml hashicorp hashicorp/consul

# log "Waiting for Consul pod to complete configuration."
# until [ `kubectl get pods | grep consul-server | grep Running | wc -l` -gt 0 ]
# do
#   sleep 5
# done

# log "Adding port forward for Consul UI"

# export IP_ADDR=$(hostname -I | awk '{print $1}')

# kubectl port-forward service/hashicorp-consul-ui 80:80 --address ${IP_ADDR} &


# log "Deploying api backend."

# kubectl apply -f ~/api.yml

# log "Deploying web backend"

# kubectl apply -f ~/web.yml

# log "Waiting for deployment to complete"

# until [ `kubectl get pods | grep -E "(web-|api-)deployment" | grep Running | wc -l`  -gt 1 ]
# do
#   sleep 5
# done

# log "Adding port forward for Web UI"

# export IP_ADDR=$(hostname -I | awk '{print $1}')

# kubectl port-forward service/web 9090:9090 --address ${IP_ADDR} &

finish

EOFSRSLY

chmod +x /tmp/provision.sh
