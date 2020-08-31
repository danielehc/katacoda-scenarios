To complete your configuration will now configure Consul using the `server.json`{{execute T1}} configuration file provided with the lab.

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

### Start Consul

Finally, start Consul:

`consul agent -config-file server.json -advertise '{{ GetInterfaceIP "ens3" }}'`{{execute T1}}

In the output, if the configuration was successful, you will get an indication in the output that TLS encryption is now enabled:

```

```