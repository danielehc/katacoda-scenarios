### Configure Consul server

The scenario comes with a prepared Consul server configuration.

Open `server.json`{{open}} in the editor to inspect values required for a minimal server config with TLS encryption enabled.

The configuration refers also to the two files created in the previous step.


### Distribute configuration files and certificates to the server

This scenario uses a Docker volume, called `server_config` to help you distribute the configuration to your server node.


Copy the required files for the Consul server configuration into the volume.

`docker cp ./server.json volumes:/server/server.json`{{execute T2}}
`docker cp ./consul-agent-ca.pem volumes:/server/consul-agent-ca.pem`{{execute T2}}
`docker cp ./dc1-server-consul-0.pem volumes:/server/dc1-server-consul-0.pem`{{execute T2}}
`docker cp ./dc1-server-consul-0-key.pem volumes:/server/dc1-server-consul-0-key.pem`{{execute T2}}

#### Start Consul server with the configuration file

Finally start the Consul server.

`docker run \
    -d \
    -v server_config:/etc/consul.d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui \
     -node=server-1 \
     -bootstrap-expect=1 \
     -client=0.0.0.0 \
     -config-file=/etc/consul.d/server.json`{{execute server}}

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
    consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0 -config-file=/etc/consul.d/server.json