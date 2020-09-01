
The Consul secrets engine generates Consul API tokens dynamically based on Consul ACL policies,
and must be enabled before it can perform its functions.

`vault secrets enable consul`{{execute T1}}

Example output:

```
Success! Enabled the consul secrets engine at: consul/
```

### Configure Vault to connect and authenticate to Consul

The secrets engine requires a management token to interact with Consul.

First, create a management token in Consul:

`consul acl token create -policy-name=global-management | tee consul.management`{{execute T1}}

Export the management token as an environment variable:

`export CONSUL_MGMT_TOKEN=$(cat consul.management  | grep SecretID  | awk '{print $2}')`{{execute T1}}

Once you have the Consul secret backend enabled,
configure access with Consul's address and management token:

`vault write consul/config/access \
    address=${CONSUL_HTTP_ADDR} \
    token=${CONSUL_MGMT_TOKEN}`{{execute T1}}

Example output:

```
Success! Data written to: consul/config/access
```

### Create a role to map names in Vault to a Consul ACL policy

For this lab, you are going to configure a role that maps a name
in Vault to a Consul ACL policy. When users generate credentials,
they are generated against this role.

`vault write consul/roles/consul-server-role policies=consul-servers`{{execute T1}}

Example output:

```
Success! Data written to: consul/roles/consul-server-role
```