
To verify the client node properly started you can query consul to retrieve the list of members.

`consul members`{{execute T1}}

```plaintext
$ consul members
Node      Address          Status  Type    Build  Protocol  DC   Segment
server-1  172.18.0.2:8301  alive   server  1.7.3  2         dc1  <all>
client-1  172.18.0.3:8301  alive   client  1.7.3  2         dc1  <default>
```

### Setup a less privileged token for CLI operations

Having your bootstrap token used in daily activities or exposed as an environment variable is **strongly discouraged** because it exposes you to several security risks. 

The best approach would be to create a specific token for the operator, associated with a policy reflecting only the minimum permissions required to perform the tasks.

For this lab you can create a simple read-only policy to inspect the content of your Consul datacenter without the possibility to make changes.

Open `read_policy.hcl`{{open}} to check the rules defined:

```plaintext
# read-only-policy.hcl
node_prefix "" {
   policy = "read"
}
service_prefix "" {
   policy = "read"
}
key-prefix "" {
   policy = "read"
}
```
Create the policy and token with the `consul acl` command.

`consul acl policy create \
  -name read-only \
  -rules @read_policy.hcl`{{execute T1}}

`consul acl token create \
  -description "read-only token" \
  -policy-name read-only | tee read-only.token`{{execute T1}}


### Change the token

The previous requests were successful because you still had the bootstrap token exported in `CONSUL_HTTP_TOKEN`.

`unset CONSUL_HTTP_TOKEN`{{execute T1}}

After unsetting it, try query Consul:

`consul members`{{execute T1}}

The fact the command now returns an empty output, indicates that ACLs are properly in place and that an anonymous client will not be able to retrieve data from Consul even if able to reach the agent.

Finally set the token for the command using the `CONSUL_HTTP_TOKEN` environment variable.

`export CONSUL_HTTP_TOKEN=$(cat read-only.token  | grep SecretID  | awk '{print $2}')`{{execute T1}}

You can now try again to retrieve the list of members from Consul.

`consul members`{{execute T1}}

