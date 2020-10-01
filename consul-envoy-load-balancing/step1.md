You can check the environment using `docker ps`{{execute}}

```
$ docker ps
CONTAINER ID        IMAGE                                   COMMAND                  CREATED             STATUS              PORTSNAMES
e3e039a76965        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        0.0.0.0:8080->8080/tcp, 0.0.0.0:8888->8888/tcp, 10000/tcpingress-gw
e7af27a71618        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        10000/tcpbackend-clone
7ffb98ec487a        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        10000/tcpbackend-main
25aac3ad4961        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        10000/tcpclient
32b4c7c2ede8        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->8600/udp, 10000/tcpserver
```

The output shows five running containers each one running a Consul agent.

This can be also verified using `consul members` on one of the containers

`docker exec server consul members`{{execute}}

```
Node        Address          Status  Type    Build     Protocol  DC   Segment
server-1    172.18.0.2:8301  alive   server  1.9.0dev  2         dc1  <all>
client-1    172.18.0.3:8301  alive   client  1.9.0dev  2         dc1  <default>
ingress-gw  172.18.0.6:8301  alive   client  1.9.0dev  2         dc1  <default>
service-1   172.18.0.4:8301  alive   client  1.9.0dev  2         dc1  <default>
service-2   172.18.0.5:8301  alive   client  1.9.0dev  2         dc1  <default>
```

In this configuration you can verify the backend service is accessible from the client container using `curl`

`docker exec client curl -s localhost:9192`{{execute}}

Example output:

```
{
  "name": "main",
  "uri": "/",
  "type": "HTTP",
  "ip_addresses": [
    "172.18.0.4"
  ],
  "start_time": "2020-10-01T16:15:54.151406",
  "end_time": "2020-10-01T16:15:54.151885",
  "duration": "478.867µs",
  "body": "Hello World",
  "code": 200
}
```

## Default load balancing policy

By default Consul balances traffic across instances of the same service using the `random` policy.

You can verify the balancing by issuing the `curl` command multiple times. 