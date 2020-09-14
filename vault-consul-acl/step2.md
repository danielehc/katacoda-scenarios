
The Consul secrets engine generates Consul API tokens dynamically based on Consul ACL policies,
and must be enabled before it can perform its functions.

`vault secrets enable consul`{{execute T1}}

Example output:

```
Success! Enabled the consul secrets engine at: consul/
```

### Configure Vault to connect and authenticate to Consul

The secrets engine requires a management token, with unrestricted privileges, to interact with Consul.

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

In the previous step you created a policy, `consul-servers`, to define servers' permissions.

You are going to use that policy when creating tokens for Consul servers.

A recommended approach to generate tokens for identical policies is to associate the policy to a role.

Roles allow for the grouping of a set of policies and service identities into a reusable higher-level entity that can be applied to many tokens.

For this lab, you are going to configure a role that maps a name
in Vault to a set of Consul ACL policies. When users generate credentials, if they are generated against this role they will automatically get associated to the policies of that role.

`vault write consul/roles/consul-server-role policies=consul-servers`{{execute T1}}

Example output:

```
Success! Data written to: consul/roles/consul-server-role
```

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Warning:</strong><br>
  
  The tokens will only be associated to the policies that are represented by the role at token creation time. If you change the role configuration, for example by associating it with a new policy, the change will only be reflected by the tokens you generate after it. Previous tokens will not be affected. 
  <br/>
  This prevents you from mistakenly associating extra permissions to pre-existing tokens.

</p></div>
