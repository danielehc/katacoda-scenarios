You can check the environment using `docker ps`:

`docker ps --format "{{.ID}}: {{.Names}}  \t {{.Ports}}"`{{execute}}

Example output:

```
21f90c9e97bd: ingress-gw  0.0.0.0:8080->8080/tcp, 0.0.0.0:8888->8888/tcp, 10000/tcp
5d7df946db5c: dashboard   10000/tcp
09e432716fa6: counter     10000/tcp
d988887de19e: server      0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->8600/udp, 10000/tcp
```

The output shows five running containers each one running a Consul agent.

This can be also verified using `consul members` on one of the containers

`docker exec server consul members`{{execute}}

```
Node        Address          Status  Type    Build     Protocol  DC   Segment
server-1    172.18.0.2:8301  alive   server  1.9.0dev  2         dc1  <all>
ingress-gw  172.18.0.5:8301  alive   client  1.9.0dev  2         dc1  <default>
service-1   172.18.0.3:8301  alive   client  1.9.0dev  2         dc1  <default>
service-2   172.18.0.4:8301  alive   client  1.9.0dev  2         dc1  <default>
```

In this configuration you can verify the counting service is accessible from the client container using `curl`

`docker exec dashboard curl -s localhost:5000`{{execute}}

Example output:

```json
{
  "count": 2,
  "hostname": "09e432716fa6"
}
```

