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

To configure TLS encryption for Consul, three files are required:

* `ca_file`   - CA (or intermediate) certificate to verify the identity of the other nodes.
* `cert_file` - Consul agent public certificate
* `key_file`  - Consul agent private key

One possible approach would be to use the files generated in the previous steps and distribute them manually to the Consul agents.

In this lab, you will automate certificate distribution using consul-template to generate and retrieve the files for you and configure short-lived certificate rotation.