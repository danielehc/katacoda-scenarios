### Configure Consul server



### Distribute configuration files and certificates to the server

This scenario uses a Docker volume, called `server_config` to help you distribute the configuration to your server node.

`docker cp ./server.json volumes:/server/server.json`{{execute T2}}
`docker cp ./consul-agent-ca.pem volumes:/server/consul-agent-ca.pem`{{execute T2}}
`docker cp ./consul-agent-ca-key.pem volumes:/server/consul-agent-ca-key.pem`{{execute T2}}


#### Start Consul server with the configuration file

docker run \
    -d \
    -v /home/scrapbook/tutorial/config:/etc/consul.d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0 
    -config-file=/etc/consul/server.json

docker run \
    -d \
    -mount type=bind,source="$(pwd)"/config,target=/etc/consul.d  \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0 
    -config-file=/etc/consul/server.json


docker exec server consul members

docker exec -it server /bin/sh

docker container rm -f server


docker volume create server_config

docker volume create client_config

docker container create --name volumes -v server_config:/server -v client_config:/client alpine

docker cp ./server.json volumes:/server/server.json
docker cp ./consul-agent-ca.pem volumes:/server/consul-agent-ca.pem
docker cp ./consul-agent-ca-key.pem volumes:/server/consul-agent-ca-key.pem

docker run \
    -d \
    -v server_config:/etc/consul.d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0 