#! /bin/bash

# ++-----------------+
# || Functions       |
# ++-----------------+

## Prints a line on stdout prepended with date and time
log() {
  echo "["$(date +"%Y-%d-%d %H:%M:%S")"] - ${@}"
}

## Prints a header on stdout
header() {

  echo -e " \e[1m\e[32m"

  echo ""
  echo "++----------- " 
  echo "||   ${@} "
  echo "++------      " 

  echo -e "\e[0m"
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

  echo "export CONSUL_HTTP_ADDR=https://${LB_IP}:443"
  echo "export CONSUL_HTTP_TOKEN=root"
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

## Purges environment by removing all containers and volumes
## Use only in case something goes wrong in the provision.
purge_env() {

  # killall consul

  docker rm -f $(docker ps -aq)
  docker volume rm $(docker volume ls -q)
  rm -rf ${ASSETS}certs
  
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
    
    docker exec $i netstat -natp | grep LISTEN; 
    
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

elif [ "$1" == "purge" ]; then

  purge_env
  exit 0

elif [ "$1" == "ports" ]; then

  show_ports
  exit 0

fi

# set -x 

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

## DNS Config
## log "Setting Consul as DNS"
## The setting below can be used on a Ubuntu VM to setup Consul as the main
## DNS for the machine. This can be useful for scenarios when Consul DNS interface
## can be bound on localhost at port 53. This is not a recommended setting and 
## requires root permissions.
# echo -en "# Consul DNS Configuration\nnameserver 127.0.0.1\n\n" > /etc/resolvconf/resolv.conf.d/head
# systemctl restart resolvconf.service

# ++-----------------+
# || Binaries        |
# ++-----------------+
## The sandbox requires Consul binary to be installed locally to perform
## configuration tasks
log "Installing Binaries Locally"

which consul &>/dev/null && {
  if [ `consul version | head -1 | awk '{print $2}'` == "v${CONSUL_VERSION}" ]; then
    ## If consul is installed and is the same version of the one we use for
    ## the sandbox we skip the installation passage.
    BIN_PATH=""
    EXTRA_PATH=""
  fi
}

## The script copies the following binaries in the $BIN_PATH

if [ ! -z "${BIN_PATH}" ] ; then
  
  # Create bin folder
  mkdir -p ${BIN_PATH}

  unameOut="$(uname -s)"

  case "${unameOut}" in
    Linux*)
      log "OS: Linux"
      
      docker run --rm --entrypoint /bin/sh \
        ${IMAGE_NAME}:${IMAGE_TAG} \
        -c "cat /usr/local/bin/consul" > ${BIN_PATH}consul

      ## envoy        - Useful in case you want to make the local node part of
      ##                service mesh and interact directly with the services
      ##                inside the mesh.
      docker run --rm --entrypoint /bin/sh \
        ${IMAGE_NAME}:${IMAGE_TAG} \
        -c "cat /usr/local/bin/envoy" > ${BIN_PATH}envoy

      ## fake-service - Useful if you want to simulate a service residing outside
      ##                the service mesh and that needs to be monitored with 
      ##                consul-esm and/or accessed using a terminating gateway. 
      docker run --rm --entrypoint /bin/sh \
        ${IMAGE_NAME}:${IMAGE_TAG} \
        -c "cat /usr/local/bin/fake-service" > ${BIN_PATH}fake-service
      ;;

    Darwin*)    
      log  "OS: MacOS"
      install_from_zip consul ${BIN_PATH} https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_darwin_amd64.zip 
      ;;
      
    *)
      echo "[ERROR] - OS: ${unameOut} not supported"
      exit 1;;
  esac 

  chmod +x ${BIN_PATH}*
  # ${BIN_PATH}consul -autocomplete-install
fi

########## ------------------------------------------------
header     "GENERATE DYNAMIC CONFIGURATION"
###### -----------------------------------------------
## In this phase you should generate the configuration you want to apply
## to your datacenter to ensure it is properly secured and reflects 
## your scenario or use case.

# ++-----------------+
# || Consul Config   |
# ++-----------------+
log "Generating Consul certificates and key"
## In a production environment you need to enable 

mkdir -p ${ASSETS}certs

## Generate configuration file for Gossip Encryption
echo "encrypt = \""$(${BIN_PATH}consul keygen)"\"" > ${ASSETS}certs/agent-gossip-encryption.hcl 

## mTLS Certificates
pushd ${ASSETS}certs > /dev/null

## Generate CA certificates (consul-agent-ca.pem & consul-agent-ca-key.pem)
# ${EXTRA_PATH}${BIN_PATH}consul tls ca create -domain="${DOMAIN}"
consul tls ca create -domain="${DOMAIN}"

## Generate Server certificates (ideally one per server)
# ==> Using consul-agent-ca.pem and consul-agent-ca-key.pem
# ==> Saved dc1-server-consul-0.pem
# ==> Saved dc1-server-consul-0-key.pem
# ${EXTRA_PATH}${BIN_PATH}consul tls cert create -server -domain="${DOMAIN}" -dc="${DATACENTER}"
consul tls cert create -server -domain="${DOMAIN}" -dc="${DATACENTER}"

popd > /dev/null

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

log "Copying configuration files" 
## The sandbox environments provides you with a full set of example files to
## be used as an example to generate your own configuration.
## TODO - Files should be passed directly at Docker container creation time.

# Server configuration files
docker cp ${ASSETS}agent-server-secure.hcl volumes:/server/agent-server-secure.hcl
docker cp ${ASSETS}agent-server-tokens.hcl volumes:/server/agent-server-tokens.hcl
docker cp ${ASSETS}certs/agent-gossip-encryption.hcl volumes:/server/agent-gossip-encryption.hcl
## Server Certificates
docker cp ${ASSETS}certs/${DOMAIN}-agent-ca.pem volumes:/server/consul-agent-ca.pem
docker cp ${ASSETS}certs/${DOMAIN}-agent-ca-key.pem volumes:/server/consul-agent-ca-key.pem
docker cp ${ASSETS}certs/${DATACENTER}-server-${DOMAIN}-0.pem volumes:/server/server-consul-0.pem
docker cp ${ASSETS}certs/${DATACENTER}-server-${DOMAIN}-0-key.pem volumes:/server/server-consul-0-key.pem

# Client configuration files
docker cp ${ASSETS}agent-client-secure.hcl volumes:/client/agent-client-secure.hcl
docker cp ${ASSETS}agent-client-tokens.hcl volumes:/client/agent-client-tokens.hcl
docker cp ${ASSETS}agent-ui-metrics.hcl volumes:/client/agent-ui-metrics.hcl
docker cp ${ASSETS}certs/agent-gossip-encryption.hcl volumes:/client/agent-gossip-encryption.hcl
## Client Certificates
docker cp ${ASSETS}certs/${DOMAIN}-agent-ca.pem volumes:/client/consul-agent-ca.pem
## Service definitions
docker cp ${ASSETS}svc-db.hcl volumes:/client/svc-db.hcl
docker cp ${ASSETS}svc-api.hcl volumes:/client/svc-api.hcl
docker cp ${ASSETS}svc-web.hcl volumes:/client/svc-web.hcl
docker cp ${ASSETS}svc-load-balancer.hcl volumes:/client/svc-load-balancer.hcl

## Service configuration files
## These files can be automatically generated using consul-template and 
## storing data into Consul KV/store. This will make the process easier
## to automate and prot to other environments.
docker cp ${ASSETS}ext-envoy-reverse-proxy.yaml volumes:/client/ext-envoy-reverse-proxy.yaml

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
    consul agent -server \
      -datacenter=${DATACENTER} \
      -domain=${DOMAIN} \
      -node=server-$i \
      -client=127.0.0.1 \
      -bootstrap-expect=${SERVER_NUMBER} \
      -retry-join=${RETRY_JOIN} \
      -config-file=/etc/consul.d/agent-server-secure.hcl \
      -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
      -config-file=/etc/consul.d/agent-server-tokens.hcl
  
  ## Retrieve newly created server IP
  SERVER_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server-$i`

  ## Generate the retry-join string
  if [ -z "${RETRY_JOIN}" ]; then 
    RETRY_JOIN=${SERVER_IP}; 
  else 
    RETRY_JOIN="${RETRY_JOIN} -retry-join=${SERVER_IP}";
  fi
done

## Simulate the startup time but also give time to slower test machines to run
## the containers.
sleep 5

## TODO ACL fine tuning
## At this point you should consider creating less privileged tokens for your
## client agents and a token for DNS interface.



########## ------------------------------------------------
header     "CONSUL - Starting Client Agents"
###### -----------------------------------------------

# ++-----------------+
# || Consul API      |
# ++-----------------+

log "Starting LB Nodes"

docker run \
  -d \
  -v client_config:/etc/consul.d \
  --name=load-balancer \
  --hostname=load-balancer \
  --label tag=learn \
  --dns=127.0.0.1 \
  --dns-search=consul \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  consul agent -ui \
    -datacenter=${DATACENTER} \
    -domain=${DOMAIN} \
    -node=load-balancer \
    -retry-join=${RETRY_JOIN} \
    -client=127.0.0.1 \
    -config-file=/etc/consul.d/agent-client-secure.hcl \
    -config-file=/etc/consul.d/agent-gossip-encryption.hcl \
    -config-file=/etc/consul.d/agent-client-tokens.hcl 
    
    # \
    # -config-file=/etc/consul.d/agent-ui-metrics.hcl

LB_IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' load-balancer`

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
    -config-file=/etc/consul.d/agent-client-tokens.hcl 

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
    -config-file=/etc/consul.d/agent-client-tokens.hcl 
     
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
    -config-file=/etc/consul.d/agent-client-tokens.hcl 
     
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
    -config-file=/etc/consul.d/agent-client-tokens.hcl 

    # -p 8443:443 \

sleep 5

########## ------------------------------------------------
header     "CONSUL - Service Mesh configuration and deploy"
###### -----------------------------------------------

# ++-----------------+
# || Config          |
# ++-----------------+

## The recommended approach for configuring Consul UI and API to be accessed
## by users and operators is to use dedicated Consul agents to server API and
## UI requests and to have them behind a reverse proxy tht could terminate
## SSL and expose a certificate that is not self signed by Consul CA but is
## emitted from a trusted CA like Let's Encrypt.

## Start LB for Consul UI
log "Espose Load Balancer on https://${LB_IP}:443"
docker exec load-balancer sh -c "envoy -c /etc/consul.d/ext-envoy-reverse-proxy.yaml --service-cluster \"targetCluster\" > /tmp/reverse-proxy.log 2>&1 &"

log "Define Environment Variables"

export CONSUL_HTTP_ADDR=https://${LB_IP}:443
export CONSUL_HTTP_TOKEN="root"
export CONSUL_HTTP_SSL=true
## This is a boolean value (default true) to specify 
# SSL certificate verification; setting this value to 
# false is not recommended for production use. 
# Example for development purposes:
export CONSUL_HTTP_SSL_VERIFY=false

sleep 2
log "Apply Configuration Entries"

# ## Envoy Proxy Defaults
# ${BIN_PATH}consul config write ${ASSETS}config-proxy-defaults.hcl

# ${BIN_PATH}consul config write ${ASSETS}config-service-db.hcl
# ${BIN_PATH}consul config write ${ASSETS}config-service-api.hcl
# ${BIN_PATH}consul config write ${ASSETS}config-service-web.hcl
# ${BIN_PATH}consul config write ${ASSETS}config-service-load-balancer.hcl

# ## Ingress gateway configuration
# ${BIN_PATH}consul config write ${ASSETS}igw-web.hcl

## Envoy Proxy Defaults
consul config write ${ASSETS}config-proxy-defaults.hcl

consul config write ${ASSETS}config-service-db.hcl
consul config write ${ASSETS}config-service-api.hcl
consul config write ${ASSETS}config-service-web.hcl
consul config write ${ASSETS}config-service-load-balancer.hcl

## Ingress gateway configuration
consul config write ${ASSETS}igw-web.hcl

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
## Register Consul API
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN='root' \
  load-balancer sh -c "consul services register /etc/consul.d/svc-load-balancer.hcl"

## Register DB service
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN='root' \
  db sh -c "consul services register /etc/consul.d/svc-db.hcl"

## Register API service
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN='root' \
  api sh -c "consul services register /etc/consul.d/svc-api.hcl"

## Register WEB service
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN='root' \
  web sh -c "consul services register /etc/consul.d/svc-web.hcl"

log "Start Envoy sidecar proxies"
## Once the services are registered in Consul and the upsytram dependencies are
## specified 

## Start db sidecar
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN='root' \
  db sh -c "consul connect envoy -sidecar-for db-1 -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"

## Start api sidecar
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN='root' \
  api sh -c "consul connect envoy -sidecar-for api-1 -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"

## Start web sidecar
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN='root' \
  web sh -c "consul connect envoy -sidecar-for web -admin-bind 0.0.0.0:19001 > /tmp/proxy.log 2>&1 &"

# ++-----------------+
# || Gateway Config  |
# ++-----------------+
log "Start Ingress Gateway for web"
docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_GRPC_ADDR='127.0.0.1:8502' \
  --env CONSUL_HTTP_TOKEN='root' \
  ingress-gw sh -c "consul connect envoy -gateway=ingress -register -service ingress-service -address '{{ GetInterfaceIP \"eth0\" }}:8888' -admin-bind 0.0.0.0:19001 > /tmp/proxy_1.log 2>&1 &"

########## ------------------------------------------------
header     "CONSUL - Configure your local environment"
###### -----------------------------------------------

print_vars

# finish
