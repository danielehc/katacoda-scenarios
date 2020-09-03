cat << 'EOFSRSLY' > /tmp/provision.sh
#! /bin/bash

log() {
  echo $(date) - ${@}
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

log "Install prerequisites"
# apt-get install -y apt-utils > /dev/null
apt-get install -y unzip curl jq > /dev/null

# log Download App 0.14.1

# curl -s https://github.com/nicholasjackson/fake-service/releases/download/v0.14.1/fake-service-linux


# log Install GO 1.5.1

# curl -s https://golang.org/dl/go1.15.1.linux-amd64.tar.gz

# tar -C /usr/local -xzf go1.14.3.linux-amd64.tar.gz

# echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile


# log Build Consul locally

# # git clone git@github.com:hashicorp/consul.git
# # cd consul

# curl -s https://github.com/hashicorp/consul/archive/envoy-lb-v2.zip

# git checkout envoy-lb-v2
# make dev


# log Install Consul locally

# # Retrieves lates version from checkpoint
# # Substitute this with APP_VERSION=x.y.z to configure a specific version.
# APP_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq .current_version | tr -d '"')

# log Installing Consul ${APP_VERSION}

# curl -s https://releases.hashicorp.com/consul/${APP_VERSION}/consul_${APP_VERSION}_linux_amd64.zip -o consul_${APP_VERSION}_linux_amd64.zip

# unzip consul_${APP_VERSION}_linux_amd64.zip > /dev/null
# chmod +x consul
# mv consul /usr/local/bin/consul

# rm -rf consul_${APP_VERSION}_linux_amd64.zip > /dev/null

# log Pulling Docker image for Consul ${APP_VERSION}

# docker pull consul:${APP_VERSION} > /dev/null

# log Creating Docker volumes

# docker volume create server_config > /dev/null

# docker volume create client_config > /dev/null

# docker container create --name volumes -v server_config:/server -v client_config:/client alpine > /dev/null

finish

EOFSRSLY

chmod +x /tmp/provision.sh
