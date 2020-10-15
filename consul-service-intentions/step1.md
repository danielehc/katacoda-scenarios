You can check the environment using `docker ps`:

`docker ps --format "{{.Names}}\t\t{{.Ports}}"`{{execute}}

Example output:

```
ingress-gw      0.0.0.0:8080->8080/tcp, 0.0.0.0:8888->8888/tcp, 10000/tcp
web             0.0.0.0:9002->9002/tcp, 0.0.0.0:19002->19002/tcp, 10000/tcp
api             10000/tcp, 0.0.0.0:19001->19001/tcp
server          0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->8600/udp, 10000/tcp
```

The output shows five running containers each one running a Consul agent.

The server port for Consul is been forwarded to the hosting node so you can use consul without the need to login to a different node or to run a local agent in order to communicate with Consul. 

You can verify this using `consul members` on the terminal

`consul members`{{execute}}

```
Node        Address          Status  Type    Build     Protocol  DC   Segment
server-1    172.18.0.2:8301  alive   server  1.9.0dev  2         dc1  <all>
ingress-gw  172.18.0.5:8301  alive   client  1.9.0dev  2         dc1  <default>
service-1   172.18.0.3:8301  alive   client  1.9.0dev  2         dc1  <default>
service-2   172.18.0.4:8301  alive   client  1.9.0dev  2         dc1  <default>
```

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Production note:</strong> This scenario runs a non-secure configuration for Consul for test purposes. In a production scenario you want to [secure Consul agent communication with TLS encryption](https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure?in=consul/security-networking) to make sure your requests to the Consul datacenter are encrypted. You also want to [secure Consul with Access Control Lists (ACLs)](https://learn.hashicorp.com/tutorials/consul/access-control-setup-production?in=consul/security-networking) to fine tune permissions you can perform from external requests.

</p></div>

In this configuration you can verify the counting service is accessible from the client container using `curl`

`docker exec dashboard curl -s localhost:5000`{{execute}}

Example output:

```json
{
  "count": 2,
  "hostname": "09e432716fa6"
}
```

