<!-- How would you feel about moving this before the Consul template step? Then in the Consul template step they can see the cert being rotated 

We could move the configuration into a specific step and explain at the bottom that we are going to automate the config part using consul-template

-->
Now configure Consul using the `server.json`{{execute T1}}
configuration file provided with the lab.

Example content:

```
{
  "verify_incoming": true,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ca_file": "/opt/consul/agent-certs/ca.crt",
  "cert_file": "/opt/consul/agent-certs/agent.crt",
  "key_file": "/opt/consul/agent-certs/agent.key",
  "auto_encrypt": {
    "allow_tls": true
  }
}
```

## Start Consul

Finally, start Consul:

`consul agent -config-file server.json -advertise '{{ GetInterfaceIP "ens3" }}'`{{execute T1}}

In the output, if the configuration was successful,
you will get an indication in the output that TLS encryption is now enabled:

```
add me
```

## Manage TLS certificates

Intro on how to distribute and rotate certs. 

### Client certificates

Managed for you by Consul

### Server certificates

Can be managed by Consul template -> continue on to learn how. 

