#! /bin/bash

log() {
  echo $(date) - ${@}
}

header() {
  echo " ++--------- " 
  echo " ||  ${1}"
  echo " ++----      " 
}

finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

log "Install prerequisites"
# apt-get install -y apt-utils > /dev/null
apt-get install -y unzip curl jq > /dev/null

log Pulling Docker Image
IMAGE_NAME=danielehc/consul-learn-image
IMAGE_TAG=v1.8.4-v1.15.0

docker pull ${IMAGE_NAME}:${IMAGE_TAG} > /dev/null

# +-------------------------------------------------------+
# | OPERATOR NODE                                         |
# +-------------------------------------------------------+
  header Configuring Operator node
# +-------------------------------------------------------+

## Idempotency attempt (TO-DO)
docker rm -f $(docker ps -aq)

## DNS Config
log - Setting Consul as DNS
echo -en "# Consul DNS Configuration\nnameserver 127.0.0.1\n\n" > /etc/resolvconf/resolv.conf.d/head
systemctl restart resolvconf.service

# ++-----------------+
# || Binaries        |
# ++-----------------+
log - Installing Binaries Locally 

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

# ++-----------------+
# || Consul Config   |
# ++-----------------+
log - Generate certificates and keys

# Gossip Encryption Key
CONSUL_GOSSIP_KEY=`consul keygen`

# mTLS Certificates
mkdir -p ./config/certs
pushd ./config/certs

consul tls ca create 
# ==> Saved consul-agent-ca.pem
# ==> Saved consul-agent-ca-key.pem

consul tls cert create -server
# ==> WARNING: Server Certificates grants authority to become a
#     server and access all state in the cluster including root keys
#     and all ACL tokens. Do not distribute them to production hosts
#     that are not server nodes. Store them as securely as CA keys.
# ==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
# ==> Saved dc1-server-consul-0.pem
# ==> Saved dc1-server-consul-0-key.pem

consul tls cert create -cli
# ==> Using consul-ca.pem and consul-ca-key.pem
# ==> Saved consul-cli-0.pem
# ==> Saved consul-cli-0-key.pem

popd

# ++-----------------+
# || Distribution    |
# ++-----------------+
log Creating Docker volumes

docker volume create server_config > /dev/null
docker volume create client_config > /dev/null
docker container create \
  --name volumes \
  -v server_config:/server \
  -v client_config:/client \
  alpine > /dev/null

log Copying configuration files 

# Server files
docker cp ./config/agent-server.hcl volumes:/server/agent-server.hcl
docker cp ./config/agent-server-secure.hcl volumes:/server/agent-server-secure.hcl

## Certs
docker cp ./config/certs/consul-agent-ca.pem volumes:/server/consul-agent-ca.pem
docker cp ./config/certs/dc1-server-consul-0.pem volumes:/server/dc1-server-consul-0.pem
docker cp ./config/certs/dc1-server-consul-0-key.pem volumes:/server/dc1-server-consul-0-key.pem

# Client files
docker cp ./config/agent-client.hcl volumes:/client/agent-client.hcl
docker cp ./config/svc-api.hcl volumes:/client/svc-api.hcl
docker cp ./config/svc-web.hcl volumes:/client/svc-web.hcl
docker cp ./config/svc-counting.json volumes:/client/svc-counting.json
docker cp ./config/svc-dashboard.json volumes:/client/svc-dashboard.json

## Certs
docker cp ./config/certs/consul-agent-ca.pem volumes:/client/consul-agent-ca.pem

# +-------------------------------------------------------+
# | SERVER AGENTS                                         |
# +-------------------------------------------------------+
  header Starting Consul Servers
# +-------------------------------------------------------+

docker run \
  -d \
  -v server_config:/etc/consul.d \
  -p 8500:8500 \
  -p 53:8600/udp \
  --name=server \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent -server -ui \
    -node=server-1 \
    -bootstrap-expect=1 \
    -client=0.0.0.0 \
    -config-file=/etc/consul.d/agent-server.hcl

# Retrieve server IP for client join
SERVER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server`

# +-------------------------------------------------------+
# | CLIENT AGENTS                                         |
# +-------------------------------------------------------+
  header Starting Consul Clients
# +-------------------------------------------------------+

# ++-----------------+
# || Services        |
# ++-----------------+

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
     -config-file=/etc/consul.d/agent-client.hcl \
     -config-file=/etc/consul.d/svc-api.hcl \
     -config-file=/etc/consul.d/svc-counting.json

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
     -config-file=/etc/consul.d/agent-client.hcl \
     -config-file=/etc/consul.d/svc-web.hcl \
     -config-file=/etc/consul.d/svc-dashboard.json

# ++-----------------+
# || Gateways        |
# ++-----------------+

## INGRESS GW
log Starting Ingress Gateway Node
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
     -config-file=/etc/consul.d/agent-client.hcl

# +-------------------------------------------------------+
# | SERVICE MESH                                          |
# +-------------------------------------------------------+
  header Starting Applications and configuring service mesh
# +-------------------------------------------------------+

# ++-----------------+
# || Config          |
# ++-----------------+
log - Apply Configuration Entries

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
log - Deploy Services and start sidecar proxies
## [FAKE-SERVICE]
docker exec api sh -c "LISTEN_ADDR=127.0.0.1:9003 NAME=api fake-service > /tmp/service.log 2>&1 &"
docker exec web sh -c "LISTEN_ADDR=0.0.0.0:9002 NAME=web UPSTREAM_URIS=\"http://localhost:5000\" fake-service > /tmp/service.log 2>&1 &"
# Start sidecar proxies
docker exec api sh -c "consul connect envoy -sidecar-for api-1 -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"
docker exec web sh -c "consul connect envoy -sidecar-for web -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"
## [FAKE-SERVICE]

# ++-----------------+
# || Federate        |
# ++-----------------+
log - Start Ingress Gateway Instance
docker exec ingress-gw sh -c "consul connect envoy -gateway=ingress -register -service ingress-service -address '{{ GetInterfaceIP \"eth0\" }}:8888' > /tmp/proxy.log 2>&1 &"

finish
