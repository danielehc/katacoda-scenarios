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
IMAGE_TAG=v1.8.4-v1.14.4
IMAGE_TAG=v1.9.0-dev6-v1.14.4

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
docker cp ./default-web.hcl volumes:/server/default-web.hcl
docker cp ./default-api.hcl volumes:/server/default-api.hcl
docker cp ./default-proxy.hcl volumes:/server/default-proxy.hcl

# Client files
docker cp ./agent.hcl volumes:/client/agent.hcl
docker cp ./svc-counting.json volumes:/client/svc-counting.json
docker cp ./svc-dashboard.json volumes:/client/svc-dashboard.json
docker cp ./igw-dashboard.hcl volumes:/client/igw-dashboard.hcl
docker cp ./svc-api.hcl volumes:/client/svc-api.hcl
docker cp ./svc-web.hcl volumes:/client/svc-web.hcl
docker cp ./igw-web.hcl volumes:/client/igw-web.hcl

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
    --name=api \
    danielehc/consul-envoy-service:${IMAGE_TAG} \
    consul agent \
     -node=service-1 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-counting.json \
     -config-file=/etc/consul.d/svc-api.hcl

docker run \
    -d \
    -v client_config:/etc/consul.d \
    --name=web \
    danielehc/consul-envoy-service:${IMAGE_TAG} \
    consul agent \
     -node=service-2 \
     -join=${SERVER_IP} \
     -config-file=/etc/consul.d/agent.hcl \
     -config-file=/etc/consul.d/svc-dashboard.json \
     -config-file=/etc/consul.d/svc-web.hcl

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
# set -x
# docker exec counter sh -c "PORT=9003 counting-service > /tmp/service.log 2>&1 &"
# docker exec dashboard sh -c "PORT=9002 COUNTING_SERVICE_URL=\"http://localhost:5000\" dashboard-service > /tmp/service.log 2>&1 &"


# Start sidecar proxies
# docker exec counter sh -c "consul connect envoy -sidecar-for counting-1 > /tmp/proxy.log 2>&1 &"
# docker exec dashboard sh -c "consul connect envoy -sidecar-for dashboard > /tmp/proxy.log 2>&1 &"
# set +x

# Start applications
set -x
docker exec api sh -c "LISTEN_ADDR=127.0.0.1:9003 NAME=api fake-service > /tmp/service.log 2>&1 &"
docker exec web sh -c "LISTEN_ADDR=127.0.0.1:9002 NAME=web UPSTREAM_URIS=\"http://localhost:5000\" fake-service > /tmp/service.log 2>&1 &"


# Start sidecar proxies
docker exec api sh -c "consul connect envoy -sidecar-for api-1 > /tmp/proxy.log 2>&1 &"
docker exec web sh -c "consul connect envoy -sidecar-for web > /tmp/proxy.log 2>&1 &"
set +x



# Configure and start ingress gateway
docker exec server consul config write /etc/consul.d/default-proxy.hcl
docker exec server consul config write /etc/consul.d/default-counting.hcl
docker exec server consul config write /etc/consul.d/default-dashboard.hcl
docker exec ingress-gw consul config write /etc/consul.d/igw-dashboard.hcl
docker exec server consul config write /etc/consul.d/default-api.hcl
docker exec server consul config write /etc/consul.d/default-web.hcl
docker exec ingress-gw consul config write /etc/consul.d/igw-web.hcl
docker exec ingress-gw sh -c "consul connect envoy -gateway=ingress -register -service ingress-service -address '{{ GetInterfaceIP \"eth0\" }}:8888' > /tmp/proxy.log 2>&1 &"

IGW_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ingress-gw`
echo "${IGW_IP} api.ingress.consul" >> /etc/hosts
echo "${IGW_IP} web.ingress.consul" >> /etc/hosts

log Starting External Applications

docker cp api:/usr/local/bin/fake-service .

finish

EOFSRSLY

chmod +x /tmp/provision.sh
