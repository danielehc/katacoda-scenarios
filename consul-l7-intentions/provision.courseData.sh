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

# IMAGE_TAG=v1.9.0-dev-v1.14.2
# IMAGE_TAG=latest
# IMAGE_TAG=v1.8.4-v1.14.2
IMAGE_TAG=v1.9.0-dev6-v1.14.2

docker pull danielehc/consul-envoy-service:${IMAGE_TAG} > /dev/null

log Creating Docker volumes

docker volume create server_config > /dev/null
docker volume create client_config > /dev/null
docker container create --name volumes -v server_config:/server -v client_config:/client alpine > /dev/null

log Copying configuration files 

# Server files
docker cp ./server.hcl volumes:/server/server.hcl
docker cp ./default-counting.hcl volumes:/server/default-counting.hcl
docker cp ./default-dashboard.hcl volumes:/server/default-dashboard.hcl

# Client files
docker cp ./agent.hcl volumes:/client/agent.hcl
docker cp ./svc-counting.json volumes:/client/svc-counting.json
docker cp ./svc-dashboard.json volumes:/client/svc-dashboard.json
docker cp ./igw-dashboard.hcl volumes:/client/igw-dashboard.hcl


log Starting Consul Server

docker run \
  -d \
  -v server_config:/etc/consul.d \
  -p 8500:8500 \
  -p 8600:8600/udp \
  --name=server \
  danielehc/consul-envoy-service:${IMAGE_TAG} \
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
    --name=counter \
    danielehc/consul-envoy-service:${IMAGE_TAG} \
    consul agent \
     -node=service-1 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-counting.json

docker run \
    -d \
    -v client_config:/etc/consul.d \
    --name=dashboard \
    danielehc/consul-envoy-service:${IMAGE_TAG} \
    consul agent \
     -node=service-2 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-dashboard.json

log Starting Ingress Gateway

docker run \
    -d \
    -v client_config:/etc/consul.d \
    -p 8888:8888 \
    -p 8080:8080 \
    --name=ingress-gw \
    danielehc/consul-envoy-service:${IMAGE_TAG} \
    consul agent \
     -node=ingress-gw \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl

log Starting Applications and configuring service mesh

# Start applications
docker exec counter sh -c "PORT=9003 NAME=main counting-service > /tmp/service.log 2>&1 &"
docker exec dashboard sh -c "PORT=9002 COUNTING_SERVICE_URL="http://localhost:5000" dashboard-service > /tmp/service.log 2>&1 &"

# Start sidecar proxies
docker exec dashboard sh -c "consul connect envoy -sidecar-for dashboard > /tmp/proxy.log 2>&1 &"
docker exec counter sh -c "consul connect envoy -sidecar-for counting-1 > /tmp/proxy.log 2>&1 &"

# Configure and start ingress gateway
docker exec server consul config write /etc/consul.d/default-counting.hcl
docker exec server consul config write /etc/consul.d/default-dashboard.hcl
docker exec ingress-gw consul config write /etc/consul.d/igw-dashboard.hcl
docker exec ingress-gw sh -c "consul connect envoy -gateway=ingress -register -service ingress-service -address '{{ GetInterfaceIP \"eth0\" }}:8888' > /tmp/proxy.log 2>&1 &"

IGW_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ingress-gw`
echo "${IGW_IP} counting.ingress.consul" >> /etc/hosts
echo "${IGW_IP} dashboard.ingress.consul" >> /etc/hosts

log Starting External Applications

docker cp dashboard:/usr/local/bin/dashboard-service .

finish

EOFSRSLY

chmod +x /tmp/provision.sh
