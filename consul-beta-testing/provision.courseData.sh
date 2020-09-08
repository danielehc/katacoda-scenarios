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

log Pulling Docker Image

docker pull danielehc/consul-envoy-service:v1.9.0-dev-v1.14.2 > /dev/null


log Creating Docker volumes

docker volume create server_config > /dev/null
docker volume create client_config > /dev/null
docker container create --name volumes -v server_config:/server -v client_config:/client alpine > /dev/null

log Copying configuration files 

# Server files
docker cp ./server.hcl volumes:/server/server.hcl
docker cp ./default.hcl volumes:/server/default.hcl
docker cp ./hash-resolver.hcl volumes:/server/hash-resolver.hcl
docker cp ./least-req-resolver.hcl volumes:/server/least-req-resolver.hcl

# Client files
docker cp ./agent.hcl volumes:/client/agent.hcl
docker cp ./svc-client.hcl volumes:/client/svc-client.hcl
docker cp ./svc-clone.hcl volumes:/client/svc-clone.hcl
docker cp ./svc-main.hcl volumes:/client/svc-main.hcl


log Starting Consul Server

docker run \
  -d \
  -v server_config:/etc/consul.d \
  -p 8500:8500 \
  -p 8600:8600/udp \
  --name=server \
  danielehc/consul-envoy-service:v1.9.0-dev-v1.14.2 \
  consul agent -server -ui \
    -node=server-1 \
    -bootstrap-expect=1 \
    -client=0.0.0.0 \
    -config-file=/etc/consul.d/server.hcl

SERVER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server`

log Starting Consul Clients

docker run \
    -d \
    -v client_config:/etc/consul.d \
    --name=client \
    consul agent \
     -node=client-1 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-client.hcl

docker run \
    -d \
    -v client_config:/etc/consul.d \
    --name=backend-main \
    consul agent \
     -node=service-1 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-main.hcl

docker run \
    -d \
    -v client_config:/etc/consul.d \
    --name=backend-clone \
    consul agent \
     -node=service-2 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-clone.hcl


log Starting Applications and configuring service mesh

# Start applications
# docker exec backend-main env LISTEN_ADDR=:9091 NAME=main fake-service
# docker exec backend-clone env LISTEN_ADDR=:9092 NAME=clone fake-service
# # docker exec client 

# Start sidecar proxies
# docker exec backend-main consul connect envoy -proxy-id backend-main-sidecar-proxy > /tmp/proxy.log &
# docker exec backend-clone consul connect envoy -admin-bind=localhost:19001 -proxy-id backend-clone-sidecar-proxy > /tmp/proxy.log &
# docker exec client consul connect envoy -admin-bind=localhost:19002 -proxy-id client-sidecar-proxy > /tmp/proxy.log &




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
