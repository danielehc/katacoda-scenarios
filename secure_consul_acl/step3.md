
Once ACLs have been bootstrapped you can use the bootstrap token to complete the configuration.

Until the token is not set for Consul operations you will not be able to perform operations or you will be presented only with a subset of results.

`consul members`{{execute T1}}

The output for the command seems to show an empty datacenter.

### Configure the token

You can set the token for the command using the `CONSUL_HTTP_TOKEN` environment variable.

`export CONSUL_HTTP_TOKEN=$(cat consul.bootstrap  | grep SecretID  | awk '{print $2}')`{{execute T1}}

You can not try again to retrieve the list of members from Consul.

`consul members`{{execute T1}}
