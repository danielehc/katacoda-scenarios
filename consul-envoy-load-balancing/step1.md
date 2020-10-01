You can check the environment using `docker ps`

```
$ docker ps
CONTAINER ID        IMAGE                                   COMMAND                  CREATED             STATUS              PORTS                                                NAMES
94db372d5eb4        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        10000/tcp                                                backend-clone
df141bc3debf        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        10000/tcp                                                backend-main
6ce5dfab87f4        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        10000/tcp                                                client
10a921a157fd        danielehc/consul-envoy-service:latest   "/entrypoint.sh cons…"   2 minutes ago       Up 2 minutes        0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->8600/udp, 10000/tcp   server
```

