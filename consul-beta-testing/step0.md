

### Start Server


docker run -d \
    --name=server \
    -p 8500:8500 \
    danielehc/consul-envoy-service:v1.9.0-dev-v1.14.2 \
    consul agent -server -ui \
        -data-dir=/tmp \
        -client=0.0.0.0 \
        -config-file=/etc/consul.d/server.hcl


### Start Client 1 FE


### Start Client 2 FE


### Start CLient 3 BE