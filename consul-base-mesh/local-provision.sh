#! /bin/bash

# ++-----------------+
# || Functions       |
# ++-----------------+

## Prints a line on stdout prepended with date and time
log() {
  echo -e "\033[1m["$(date +"%Y-%d-%d %H:%M:%S")"] - ${@}\033[0m"
}

## Prints a header on stdout
header() {

  echo -e " \033[1m\033[32m"

  echo ""
  echo "++----------- " 
  echo "||   ${@} "
  echo "++------      " 

  echo -e "\033[0m"
}

# Install_from_zip "consul" "<destination>" "https://example.com/consul.zip"
install_from_zip() {
  NAME="$1"
  DESTINATION="$2"
  DOWNLOAD_URL="$3"

  mkdir -p /tmp

  curl -s -L -o /tmp/${NAME}.zip ${DOWNLOAD_URL}

  if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
  fi

  unzip -o -d ${DESTINATION} /tmp/${NAME}.zip
  chmod +x ${DESTINATION}${NAME}
  rm -rf /tmp/${NAME}.zip
}

## Katacoda function
finish() {
  touch /provision_complete
  log "Complete!  Move on to the next step."
}

## Prints environment variables to be used to configur local machine
print_vars() {

  echo "export CONSUL_HTTP_ADDR=https://${SERVER_IP}:443"
  echo "export CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}"
  echo "export CONSUL_HTTP_SSL=true"
  ## This is a boolean value (default true) to specify 
  # SSL certificate verification; setting this value to 
  # false is not recommended for production use. 
  # Example for development purposes:
  echo "export CONSUL_HTTP_SSL_VERIFY=false"

}

## Cleans environment by removing containers and volumes
clean_env() {

  if [[ $(docker ps -aq --filter label=tag=learn) ]]; then
    docker rm -f $(docker ps -aq --filter label=tag=learn)
  fi

  if [[ $(docker ps -aq --filter label=tag=learn) ]]; then
    docker volume rm $(docker volume ls -q --filter label=tag=learn)
  fi

  ## Remove certificates 
  rm -rf ${ASSETS}certs
  
  ## Unset variables
  unset CONSUL_HTTP_ADDR
  unset CONSUL_HTTP_TOKEN
  unset CONSUL_HTTP_SSL
  unset CONSUL_CACERT
  unset CONSUL_CLIENT_CERT
  unset CONSUL_CLIENT_KEY

}

## Prints for each container the ports used
## and the process listening on those ports.
show_ports() {
  for i in `docker container ls --filter label=tag=learn --format "{{.Names}}"`; do 
    
    CONT_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $i`
    
    echo "======================="; 
    echo -e "$i - ${CONT_IP}"; 
    echo "======================="; 
    
    # docker exec $i netstat -natp | grep LISTEN; 
    docker exec $i netstat -natp | grep LISTEN | awk '{print $7"\t: "$4}' | sed 's/[0-9]*\///g' | sort ; 
    
    echo ""
  done

}

# ++-----------------+
# || Variables       |
# ++-----------------+

## Number of servers to spin up 3 or 5 is the recommended set to pass in a
## production environment
SERVER_NUMBER=3
## For the sandbox we used a Docker container to simulate a VM-like scenario
## The Docker image was built starting from envoyproxy/envoy-alpine to easily
## provide the Envoy proxy and Consul binary was added alongside with a go
## application (/usr/local/bin/fake-service) that will be used to simulate a
## three-tier application scenario.
IMAGE_NAME=danielehc/consul-learn-image
## The IMAGE_TAG follows the pattern "v<consul-version>-v<envoy-version>"
## Not all combinations are fully supported by Consul. Refer to 
## https://www.consul.io/docs/connect/proxies/envoy#supported-versions
## to make sure you are using a version that is fully compatible.
CONSUL_VERSION=1.9.0
ENVOY_VERSION=1.16.0
IMAGE_TAG=v${CONSUL_VERSION}-v${ENVOY_VERSION}

## [Optional] CUSTOMIZE THE SANDBOX
## By modifying the variables IMAGE_NAME and IMAGE_TAG it is possible to 
## change the Docker image used by default in the sandbox environment. 
## You can try creating your own using HashiCorp Packer or your usual 
## workflow to produce Docker images. 

## Define datacenter and domain for the sandbox Consul DC
DATACENTER="sandbox"
DOMAIN="consul"

## TODO: unify Katacoda and local variables

##
ASSETS="./config"
BIN_PATH="/usr/local/bin/"
DNS_PORT="53"
EXTRA_PATH=""

ASSETS="./assets/"
BIN_PATH="./bin/"
EXTRA_PATH="../../"
DNS_PORT="8600"

## Not sure on this
PATH=`pwd ${BIN_PATH}`/${BIN_PATH}:$PATH

# ++-----------------+
# || Begin           |
# ++-----------------+

## Check Parameters
if   [ "$1" == "clean" ]; then

  clean_env
  exit 0

elif [ "$1" == "ports" ]; then

  show_ports
  exit 0

fi

########## ------------------------------------------------
header     "PREREQUISITES CHECK"
###### -----------------------------------------------

## log "Verify base prerequisites"
## TODO Check Docker
## TODO Check Permissions


## TODO Idempotency attempt
log "Cleaning Environment"
## The script will try to remove automatically old instances from previous
## run attempts. As a logical step this represents a moment when we ensure
## there are no possible conflicts between the deploy we are about to perform
## and any other object that is already running in our network. 
clean_env

log "Install prerequisites"
## This part is commented as it requires root or sudo permissions to
## be executed and is only compatible with Debian and derivates.
## As a logical step consider this the moment when you install the
## tools needed to interact with your network to be able to monitor
## the environment once deployed.
# apt-get install -y apt-utils > /dev/null
# apt-get install -y unzip curl jq 2>&1 > /dev/null

log "Pulling Docker Images"

## Default Image used for all the agents except when specified
## differently in the docker run command.
docker pull ${IMAGE_NAME}:${IMAGE_TAG} > /dev/null

########## ------------------------------------------------
header     "GENERATE DYNAMIC CONFIGURATION"
###### -----------------------------------------------
## In this phase you should generate the configuration you want to apply
## to your datacenter to ensure it is properly secured and reflects 
## your scenario or use case.

log "Starting Operator container"
docker run \
  -d \
  -v ${PWD}/assets:/assets \
  --user $(id -u):$(id -g) \
  --name=operator \
  --hostname=operator \
  --label tag=learn \
  ${IMAGE_NAME}:${IMAGE_TAG} "" > /dev/null 2>&1

log "Generating Consul certificates and key"

docker exec \
  -w /assets \
  operator bash -c "mkdir -p ./certs; \
                    cd ./certs; \
                    echo encrypt = '\"$(consul keygen)\"' > agent-gossip-encryption.hcl; \
                    consul tls ca create -domain=\"${DOMAIN}\"; \
                    for ((i = 1 ; i <= ${SERVER_NUMBER} ; i++)); do consul tls cert create -server -domain=${DOMAIN} -dc=${DATACENTER}; done" 

########## ------------------------------------------------
header     "DISTRIBUTE CONFIGURATION"
###### -----------------------------------------------

log "Creating Docker volumes"
## To simplify configuration the initial iterations of the sandbox environment
## the files are stored in two Docker volumes "client" and "server" that hold
## all the configuration files needed by all the different agents.

## In a production environment you want the files to be distributed only to the
## agents that need them to avoid secret sprawl and to be able to fine tune the
## configuration for the different agents.
docker volume create --label tag=learn server_config > /dev/null
docker volume create --label tag=learn client_config > /dev/null

docker container create \
  --name volumes \
  --label tag=learn \
  -v server_config:/server \
  -v client_config:/client \
  alpine > /dev/null

log "Copying server configuration files" 
## The sandbox environments provides you with a full set of example files to
## be used as an example to generate your own configuration.
## TODO - Files should be passed directly at Docker container creation time.

# Server configuration files
docker cp ${ASSETS}agent-server-secure.hcl volumes:/server/agent-server-secure.hcl
# docker cp ${ASSETS}certs/agent-server-tokens.hcl volumes:/server/agent-server-tokens.hcl
docker cp ${ASSETS}certs/agent-gossip-encryption.hcl volumes:/server/agent-gossip-encryption.hcl
## Server Certificates
docker cp ${ASSETS}certs/${DOMAIN}-agent-ca.pem volumes:/server/consul-agent-ca.pem
docker cp ${ASSETS}certs/${DOMAIN}-agent-ca-key.pem volumes:/server/consul-agent-ca-key.pem

i=0
# for i in `seq 0 $(($SERVER_NUMBER -1))`; do
docker cp ${ASSETS}certs/${DATACENTER}-server-${DOMAIN}-$i.pem volumes:/server/server-consul.pem
docker cp ${ASSETS}certs/${DATACENTER}-server-${DOMAIN}-$i-key.pem volumes:/server/server-consul-key.pem
# done

# Client configuration files
docker cp ${ASSETS}agent-client-secure.hcl volumes:/client/agent-client-secure.hcl
# docker cp ${ASSETS}agent-client-tokens.hcl volumes:/client/agent-client-tokens.hcl
docker cp ${ASSETS}agent-ui-metrics.hcl volumes:/client/agent-ui-metrics.hcl
docker cp ${ASSETS}certs/agent-gossip-encryption.hcl volumes:/client/agent-gossip-encryption.hcl
## Client Certificates
docker cp ${ASSETS}certs/${DOMAIN}-agent-ca.pem volumes:/client/consul-agent-ca.pem
## Service definitions
docker cp ${ASSETS}svc-db.hcl volumes:/client/svc-db.hcl
docker cp ${ASSETS}svc-api.hcl volumes:/client/svc-api.hcl
docker cp ${ASSETS}svc-web.hcl volumes:/client/svc-web.hcl

########## ------------------------------------------------
header     "CONSUL - Starting Server Agents"
###### -----------------------------------------------

## This string will be populated with the server IPs to form the retry join
## for the other servers and clients. When running Consul on a cloud provider
## or on kubernetes it is possible to use the cloud auto join configuration.
## Read more: https://www.consul.io/docs/agent/options.html#cloud-auto-joining
RETRY_JOIN=""

for i in $(seq 1 ${SERVER_NUMBER}); do 

  log "Starting Consul server $i"
  docker run \
    -d \
    -v server_config:/etc/consul.d \
    --name=server-$i \
    --hostname=server-$i \
    --label tag=learn \
    --dns=127.0.0.1 \
    --dns-search=consul \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    consul agent -server -ui \
      -datacenter=${DATACENTER} \
      -domain=${DOMAIN} \
      -node=server-$i \
      -client=127.0.0.1 \
      -bootstrap-expect=${SERVER_NUMBER} \
      -retry-join=${RETRY_JOIN} \
      -config-file=/etc/consul.d/agent-server-secure.hcl \
      -config-file=/etc/consul.d/agent-gossip-encryption.hcl > /dev/null 2>&1
  
  ## Retrieve newly created server IP
  SERVER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server-$i`

  ## Generate the retry-join string
  if [ -z "${RETRY_JOIN}" ]; then 
    RETRY_JOIN=${SERVER_IP}; 
  else 
    RETRY_JOIN="${RETRY_JOIN} -retry-join=${SERVER_IP}";
  fi
done

## TODO ACL fine tuning
## At this point you should consider creating less privileged tokens for your
## client agents and a token for DNS interface.
########## ------------------------------------------------
header     "CONSUL - ACL configuration"
###### -----------------------------------------------

log "ACL Bootstrap"

docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "while ! consul acl bootstrap > ./certs/acl-bootstrap.conf 2> /dev/null; do echo 'ACL system not ready. Retrying...'; sleep 5; done"

export CONSUL_HTTP_TOKEN=`cat ${ASSETS}/certs/acl-bootstrap.conf | grep SecretID | awk '{print $2}'`

log "Create ACL Policies"
## DNS Policy for default tokens
docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul acl policy create -name 'acl-policy-dns' -description 'Policy for DNS endpoints' -rules @acl-policy-dns.hcl  > /dev/null 2>&1"

## Server Agent policy for server agent token
docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul acl policy create -name 'acl-policy-server-node' -description 'Policy for Server nodes' -rules @acl-policy-server-node.hcl  > /dev/null 2>&1"

log "Create ACL Tokens"

docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul acl token create -description 'DNS - Default token' -policy-name acl-policy-dns > ./certs/acl-dns-token.conf 2> /dev/null"

DNS_TOK=`cat ${ASSETS}certs/acl-dns-token.conf | grep SecretID | awk '{print $2}'` 


## Create one agent token per server
for i in `seq 1 ${SERVER_NUMBER}`; do

  IP_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server-$i`

  docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul acl token create -description \"server-$i agent token\" -policy-name acl-policy-server-node > ./certs/acl-server-$i-token.conf 2> /dev/null"

  TOK=`cat ${ASSETS}certs/acl-server-$i-token.conf | grep SecretID | awk '{print $2}'`

  docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${IP_ADDR}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul acl set-agent-token agent ${TOK}"

  docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${IP_ADDR}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul acl set-agent-token default ${DNS_TOK}"

done

########## ------------------------------------------------
header     "CONSUL - Service Mesh configuration"
###### -----------------------------------------------

log "Apply Configuration Entries"

## Envoy Proxy Defaults
docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul config write config-proxy-defaults.hcl"

## Service defaults
docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul config write config-service-db.hcl"

docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul config write config-service-api.hcl" 

docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul config write config-service-web.hcl"

## Ingress gateway configuration
docker exec \
  -w /assets \
  --env CONSUL_HTTP_ADDR=https://${SERVER_IP}:443 \
  --env CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN} \
  --env CONSUL_HTTP_SSL=true \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  operator bash -c "consul config write igw-web.hcl"

########## ------------------------------------------------
header     "CONSUL - Starting Client Agents"
###### -----------------------------------------------

## TODO: Generate different token for client nodes
tee ${ASSETS}certs/agent-client-tokens.hcl > /dev/null << EOF
acl {
  tokens {
    agent  = "${CONSUL_HTTP_TOKEN}"
    default  = "${DNS_TOK}"
  }
}
EOF

docker cp ${ASSETS}certs/agent-client-tokens.hcl volumes:/client/agent-client-tokens.hcl

CONSUL_AGENT_TOKEN=${CONSUL_HTTP_TOKEN}

# ++-----------------+
# || Services        |
# ++-----------------+
log "Starting Service Nodes"

## BACKEND
docker run \
  -d \
  -v client_config:/etc/consul.d \
  -p 19001:19001 \
  --name=db \
  --hostname=db \
  --label tag=learn \
  --dns=127.0.0.1 \
  --dns-search=consul \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent \
    -datacenter=${DATACENTER} \
    -domain=${DOMAIN} \
    -node=service-1 \
    -retry-join=${RETRY_JOIN} \
    -config-file=/etc/consul.d/agent-client-secure.hcl \
    -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
    -config-file=/etc/consul.d/agent-client-tokens.hcl > /dev/null 2>&1

## API
docker run \
  -d \
  -v client_config:/etc/consul.d \
  -p 19002:19001 \
  --name=api \
  --hostname=api \
  --label tag=learn \
  --dns=127.0.0.1 \
  --dns-search=consul \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent \
    -datacenter=${DATACENTER} \
    -domain=${DOMAIN} \
    -node=service-2 \
    -retry-join=${RETRY_JOIN} \
    -config-file=/etc/consul.d/agent-client-secure.hcl \
    -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
    -config-file=/etc/consul.d/agent-client-tokens.hcl > /dev/null 2>&1
     
    #  \
    #  -config-file=/etc/consul.d/svc-api.hcl 

## FRONTEND
docker run \
  -d \
  -v client_config:/etc/consul.d \
  -p 19003:19001 \
  -p 9002:9002 \
  --name=web \
  --hostname=web \
  --label tag=learn \
  --dns=127.0.0.1 \
  --dns-search=consul \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent \
    -datacenter=${DATACENTER} \
    -domain=${DOMAIN} \
    -node=service-3 \
    -retry-join=${RETRY_JOIN} \
    -config-file=/etc/consul.d/agent-client-secure.hcl \
    -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
    -config-file=/etc/consul.d/agent-client-tokens.hcl > /dev/null 2>&1
     
    #  \
    #  -config-file=/etc/consul.d/svc-web.hcl

# ++-----------------+
# || Gateways        |
# ++-----------------+

## INGRESS GW
log "Starting Ingress Gateway Node"
docker run \
  -d \
  -v client_config:/etc/consul.d \
  -p 8080:8080 \
  --name=ingress-gw \
  --hostname=ingress-gw \
  --label tag=learn \
  --dns=127.0.0.1 \
  --dns-search=consul \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent \
    -datacenter=${DATACENTER} \
    -domain=${DOMAIN} \
    -node=ingress-gw \
    -retry-join=${RETRY_JOIN} \
    -config-file=/etc/consul.d/agent-client-secure.hcl \
    -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
    -config-file=/etc/consul.d/agent-client-tokens.hcl > /dev/null 2>&1

    # -p 8443:443 \

sleep 5

# ++-----------------+
# || Deploy          |
# ++-----------------+

log "Deploy Services"
## In the sandbox scenario the nodes that run the services are created at startup
## so the applications do not exist before. In a real-life scenario you might have
## your services already running. In that case you will have to make sure they will
## listen on localhost to interact with the sidecar proxies you'll spin up later.

## In a zero-trust environments the services will only listen on localhost and will 
## not be exposed directly from the nodes. Consul and Envoy will be responsible for
## the service to service communication.
## Start DB
docker exec db sh -c "LISTEN_ADDR=127.0.0.1:9004 NAME=db fake-service > /tmp/service.log 2>&1 &"
## Start API
docker exec api sh -c "LISTEN_ADDR=127.0.0.1:9003 NAME=api UPSTREAM_URIS=\"http://localhost:5000\" fake-service > /tmp/service.log 2>&1 &"
## Start WEB
docker exec web sh -c "LISTEN_ADDR=0.0.0.0:9002 NAME=web UPSTREAM_URIS=\"http://localhost:5000\" fake-service > /tmp/service.log 2>&1 &"

log "Register services and checks in Consul"
## Register DB service
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  db sh -c "consul services register /etc/consul.d/svc-db.hcl"

## Register API service
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  api sh -c "consul services register /etc/consul.d/svc-api.hcl"

## Register WEB service
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  web sh -c "consul services register /etc/consul.d/svc-web.hcl"

log "Start Envoy sidecar proxies"
## Once the services are registered in Consul and the upsytram dependencies are
## specified 

## Start db sidecar
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  db sh -c "consul connect envoy -sidecar-for db-1 -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"

## Start api sidecar
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  api sh -c "consul connect envoy -sidecar-for api-1 -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"

## Start web sidecar
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  web sh -c "consul connect envoy -sidecar-for web -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"

# ++-----------------+
# || Gateway Config  |
# ++-----------------+
log "Start Ingress Gateway for web"
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_AGENT_TOKEN}" \
  ingress-gw sh -c "consul connect envoy -gateway=ingress -register -service ingress-service -address '{{ GetInterfaceIP \"eth0\" }}:8888' -admin-bind 0.0.0.0:19001 > /tmp/proxy_1.log 2>&1 &"

########## ------------------------------------------------
header     "CONSUL - Configure your local environment"
###### -----------------------------------------------

print_vars

# finish
