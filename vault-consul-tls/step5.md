Finally, start Consul:

`mkdir -p /tmp/consul`{{execute T1}}

`consul agent -config-file server.json -advertise '{{ GetInterfaceIP "ens3" }}' -data-dir=/tmp/consul`{{execute T1}}

In the output, if the configuration was successful,
you will get an indication in the output that TLS encryption is now enabled:

```
==> Starting Consul agent...
           Version: '1.8.3'
           Node ID: '61d2c6c7-60e3-d856-78c3-37b47dcdbef0'
         Node name: 'host01'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: true)
       Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, gRPC: -1, DNS: 8600)
      Cluster Addr: 172.17.0.79 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: true, TLS-Incoming: true, Auto-Encrypt-TLS: true

==> Log data will now stream in as it occurs:
```

## Use CLI certificates



## Manage TLS certificates

Intro on how to distribute and rotate certs. 

### Client certificates

Managed for you by Consul

### Server certificates

Can be managed by Consul template -> continue on to learn how. 

