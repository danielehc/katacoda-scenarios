#### Start Consul server with the configuration file

docker run \
    -d \
    -v ${pwd}/:/etc/consul/ \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0 -config-file=/etc/consul/server.json

docker exec server consul members

docker exec -it server /bin/sh


-v ${pwd}/envoy_demo.hcl:/etc/consul/envoy_demo.hcl

Once Kubernetes is running you can the official Consul Helm chart repo directly from the commandline.

`helm repo add hashicorp https://helm.releases.hashicorp.com`{{execute}}

#### Configure Consul service mesh

The scenario comes with a prepared configuration.

`consul-values.yml`{{open}}

#### Deploy Consul with Helm

`helm install -f ~/consul-values.yml hashicorp hashicorp/consul`{{execute}}

#### Check services running in Kubernetes

Control Consul is properly running.

`kubectl get services`{{execute}}

