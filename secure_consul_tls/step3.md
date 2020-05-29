### Configure Consul client

The scenario comes with a prepared Consul client configuration.

Open `client.json`{{open}} in the editor to inspect values required for a minimal client config with TLS encryption enabled.

In this scenario you are going to use the `auto_encrypt` functionality of Consul that will automatically generate and distribute certificates for the client agents once the datacenter is configured.

You will still require to refer to the CA certificate `consul-agent-ca.pem` to validate requests.

### Distribute configuration files and certificates to the client

This scenario uses a Docker volume, called `client_config` to help you distribute the configuration to your server node.


Copy the required files for the Consul server configuration into the volume.

`docker cp ./client.json volumes:/client/client.json`{{execute client}}
`docker cp ./consul-agent-ca.pem volumes:/server/consul-agent-ca.pem`{{execute client}}


#### Start Consul client with the configuration file

Finally start the Consul client.