### Configure and Start Consul

This labs comes with a prepared Consul server configuration.

Open `server.hcl`{{open}} in the editor to review the values required for a minimal server configuration with gossip encryption enabled.

Notice that the configuration includes a line that requires manual editing.

```
encrypt = "<insert gossip encryption here>"
```

Insert the previously generated gossip key in the configuration file and save.

## Start Consul

First create the data directory for Consul as configured in the `server.hcl` file.

`mkdir /opt/consul`{{execute}}

Finally start Consul.

`consul agent -config-file server.hcl -advertise '{{ GetInterfaceIP "ens3" }}'`{{execute T1}}


In the output, if the configuration was successful you will get an indication in the output that gossip encryption is now enabled:

```
==> Starting Consul agent...
           Version: '1.8.2'
           Node ID: '7ebe9143-a085-7a37-33dc-23db6cd39a80'
         Node name: 'server1'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: false)
       Client Addr: [0.0.0.0] (HTTP: 8500, HTTPS: -1, gRPC: -1, DNS: 8600)
      Cluster Addr: 172.17.0.33 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: true, TLS-Outgoing: false, TLS-Incoming: false, Auto-Encrypt-TLS: false
```