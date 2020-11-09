#! /bin/bash

log() {
  echo $(date) - ${@}
}

header() {
  echo ""
  echo ""
  echo "++----------- " 
  echo "||   ${@} "
  echo "++------      " 
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

########## ------------------------------------------------
header     "CONFIGURING OPERATOR NODE"
###### -----------------------------------------------

log "Install prerequisites"
# apt-get install -y apt-utils > /dev/null
apt-get install -y unzip curl jq > /dev/null

log "Pulling Docker Image"
IMAGE_NAME=danielehc/consul-learn-image
# IMAGE_TAG=v1.8.4-v1.15.0
IMAGE_TAG=v1.8.4-v1.14.4

docker pull ${IMAGE_NAME}:${IMAGE_TAG} > /dev/null

## Idempotency attempt (TO-DO)
# docker rm -f $(docker ps -aq)

## DNS Config
log "Setting Consul as DNS"
echo -en "# Consul DNS Configuration\nnameserver 127.0.0.1\n\n" > /etc/resolvconf/resolv.conf.d/head
systemctl restart resolvconf.service

# ++-----------------+
# || Binaries        |
# ++-----------------+
log "Installing Binaries Locally"

## consul
docker run --rm --entrypoint /bin/sh \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  -c "cat /usr/local/bin/consul" > /usr/local/bin/consul

chmod +x /usr/local/bin/consul

consul -autocomplete-install

## fake-service
docker run --rm --entrypoint /bin/sh \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  -c "cat /usr/local/bin/fake-service" > /usr/local/bin/fake-service

########## ------------------------------------------------
header     "GENERATE CONFIGURATION"
###### -----------------------------------------------

# ++-----------------+
# || Consul Config   |
# ++-----------------+
log "Generating Consul certificates and key"

## Gossip Encryption Key
echo "encrypt = \""$(consul keygen)"\"" > ./config/agent-gossip-encryption.hcl 

## mTLS Certificates
mkdir -p ./config/certs
pushd ./config/certs

## Generate CA certificates 
# ==> Saved consul-agent-ca.pem
# ==> Saved consul-agent-ca-key.pem
consul tls ca create 

## Generate Server certificates (ideally one per server)
# ==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
# ==> Saved dc1-server-consul-0.pem
# ==> Saved dc1-server-consul-0-key.pem
consul tls cert create -server

## Generate CLI certificate for running Consul locally
# ==> Using consul-ca.pem and consul-ca-key.pem
# ==> Saved dc1-cli-consul-0.pem
# ==> Saved dc1-cli-consul-0-key.pem
consul tls cert create -cli

popd

########## ------------------------------------------------
header     "DISTRIBUTE CONFIGURATION"
###### -----------------------------------------------

log "Creating Docker volumes"

docker volume create server_config > /dev/null
docker volume create client_config > /dev/null
docker container create \
  --name volumes \
  -v server_config:/server \
  -v client_config:/client \
  alpine > /dev/null

log "Copying configuration files" 

# Server configuration files
docker cp ./config/agent-server.hcl volumes:/server/agent-server.hcl
docker cp ./config/agent-server-secure.hcl volumes:/server/agent-server-secure.hcl
docker cp ./config/agent-gossip-encryption.hcl volumes:/server/agent-gossip-encryption.hcl
## Server Certificates
docker cp ./config/certs/consul-agent-ca.pem volumes:/server/consul-agent-ca.pem
docker cp ./config/certs/dc1-server-consul-0.pem volumes:/server/dc1-server-consul-0.pem
docker cp ./config/certs/dc1-server-consul-0-key.pem volumes:/server/dc1-server-consul-0-key.pem

# Client configuration files
docker cp ./config/agent-client.hcl volumes:/client/agent-client.hcl
docker cp ./config/agent-client-secure.hcl volumes:/client/agent-client-secure.hcl
docker cp ./config/agent-gossip-encryption.hcl volumes:/client/agent-gossip-encryption.hcl
docker cp ./config/svc-api.hcl volumes:/client/svc-api.hcl
docker cp ./config/svc-web.hcl volumes:/client/svc-web.hcl
## Client Certificates
docker cp ./config/certs/consul-agent-ca.pem volumes:/client/consul-agent-ca.pem
docker cp ./config/certs/dc1-cli-consul-0.pem volumes:/client/dc1-cli-consul-0.pem
docker cp ./config/certs/dc1-cli-consul-0-key.pem volumes:/client/dc1-cli-consul-0-key.pem
########## ------------------------------------------------
header     "CONSUL - Starting Server Agents"
###### -----------------------------------------------

docker run \
  -d \
  -v server_config:/etc/consul.d \
  -p 8500:8500 \
  -p 8501:8501 \
  -p 53:8600/udp \
  --name=server \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent -server -ui \
    -node=server-1 \
    -bootstrap-expect=1 \
    -client=0.0.0.0 \
    -config-file=/etc/consul.d/agent-server-secure.hcl \
    -config-file=/etc/consul.d/agent-gossip-encryption.hcl

# Retrieve server IP for client join
SERVER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server`

########## ------------------------------------------------
header     "CONSUL - Starting Client Agents"
###### -----------------------------------------------

# ++-----------------+
# || Services        |
# ++-----------------+
log "Starting Service Nodes"

## BACKEND (TO-DO)

## API
docker run \
    -d \
    -v client_config:/etc/consul.d \
    -p 19001:19001 \
    --name=api \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    consul agent \
     -node=service-1 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent-client-secure.hcl \
     -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
     -config-file=/etc/consul.d/svc-api.hcl 

## FRONTEND
docker run \
    -d \
    -v client_config:/etc/consul.d \
    -p 19002:19001 \
    -p 9002:9002 \
    --name=web \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    consul agent \
     -node=service-2 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent-client-secure.hcl \
     -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
     -config-file=/etc/consul.d/svc-web.hcl

# ++-----------------+
# || Gateways        |
# ++-----------------+

## INGRESS GW
log "Starting Ingress Gateway Node"
docker run \
    -d \
    -v client_config:/etc/consul.d \
    -p 8888:8888 \
    -p 8080:8080 \
    --name=ingress-gw \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    consul agent \
     -node=ingress-gw \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent-client-secure.hcl \
     -config-file=/etc/consul.d/agent-gossip-encryption.hcl

########## ------------------------------------------------
header     "CONSUL - Service Mesh configuration and deploy"
###### -----------------------------------------------

# ++-----------------+
# || Config          |
# ++-----------------+
log "Define Environment Variables"

# TODO
## Environment Variables needed
export CONSUL_HTTP_ADDR=127.0.0.1:8500
export CONSUL_HTTP_TOKEN="root"
export CONSUL_HTTP_SSL=true
export CONSUL_CACERT=./config/certs/consul-agent-ca.pem
export CONSUL_CLIENT_CERT=./config/certs/dc1-cli-consul-0.pem
export CONSUL_CLIENT_KEY=./config/certs/dc1-cli-consul-0-key.pem

log "Apply Configuration Entries"

## Envoy Proxy Defaults
consul config write ./config/config-proxy-defaults.hcl

## fake-service web/api
consul config write ./config/config-service-api.hcl
consul config write ./config/config-service-web.hcl
consul config write ./config/igw-web.hcl

## Default Deny intention
## [TODO] will be enabled by ACL default policy
# consul config write ./config/config-intentions-default.hcl

# ++-----------------+
# || Deploy          |
# ++-----------------+
log "Deploy Services and start sidecar proxies"
## [FAKE-SERVICE]
docker exec api sh -c "LISTEN_ADDR=127.0.0.1:9003 NAME=api fake-service > /tmp/service.log 2>&1 &"
docker exec web sh -c "LISTEN_ADDR=0.0.0.0:9002 NAME=web UPSTREAM_URIS=\"http://localhost:5000\" fake-service > /tmp/service.log 2>&1 &"
# Start sidecar proxies

## Environment Variables needed
# CONSUL_HTTP_ADDR=127.0.0.1:8500
# CONSUL_HTTP_TOKEN="root"
# CONSUL_HTTP_SSL=true
# CONSUL_CACERT=ca.crt
# CONSUL_CLIENT_CERT=client.crt
# CONSUL_CLIENT_KEY=client.key

docker exec api sh -c "consul connect envoy -sidecar-for api-1 -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"
docker exec web sh -c "consul connect envoy -sidecar-for web -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"
## [FAKE-SERVICE]

# ++-----------------+
# || Gateway Config  |
# ++-----------------+
log "Start Ingress Gateway Instance"
docker exec ingress-gw sh -c "consul connect envoy -gateway=ingress -register -service ingress-service -address '{{ GetInterfaceIP \"eth0\" }}:8888' > /tmp/proxy.log 2>&1 &"

finish
