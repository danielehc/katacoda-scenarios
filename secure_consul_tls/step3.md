### Configure Consul client

The scenario comes with a prepared Consul client configuration.

Open `client.json`{{open}} in the editor to inspect values required for a minimal client config with TLS encryption enabled.

In this scenario you are going to use the `auto_encrypt` functionality of Consul that will automatically generate and distribute certificates for the client agents once the datacenter is configured.

You will still require to refer to the CA certificate `consul-agent-ca.pem` to validate requests.

### Distribute configuration files and certificates to the client

This scenario uses a Docker volume, called `client_config` to help you distribute the configuration to your server node.


Copy the required files for the Consul server configuration into the volume.

`docker cp ./client.json volumes:/client/client.json`{{execute client}}
`docker cp ./consul-agent-ca.pem volumes:/server/consul-agent-ca.pem`{{execute client}}

### Retrieve Server IP to join the datacenter

`export CONSUL_HTTP_ADDR=$(docker exec server consul members | grep server-1 | awk '{print $2}' | sed 's/:.*//g')`{{execute T1}}

#### Start Consul client with the configuration file

Finally start the Consul client.

`docker run \
    -d
    -v client_config:/etc/consul.d \
    --name=client \
    consul agent \
     -node=client-1 \
     -join=${CONSUL_HTTP_ADDR} \
     -config-file=/etc/consul/server.json`{{execute T3}}


#### Confirm client started and joined the datacenter

`docker exec server consul members`{execute T2}}



docker run \
    -d \
    -v /home/scrapbook/tutorial/config:/etc/consul.d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=client \
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