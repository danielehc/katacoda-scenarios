Finally, start Consul:

`consul agent -config-file server.json -advertise '{{ GetInterfaceIP "ens3" }}'`{{execute T1}}

In the output, if the configuration was successful,
you will get an indication in the output that TLS encryption is now enabled:

```
add me
```

## Use CLI certificates



## Manage TLS certificates

Intro on how to distribute and rotate certs. 

### Client certificates

Managed for you by Consul

### Server certificates

Can be managed by Consul template -> continue on to learn how. 

