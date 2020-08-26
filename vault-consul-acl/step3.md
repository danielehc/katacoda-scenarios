## Need to start Consul first with ACL enabled

`vault write consul/config/access \
    address=${CONSUL_HTTP_ADDR} \
    token=${CONSUL_HTTP_TOKEN}`{{execute T1}}


Once you have the consul secret backend enabled, configure access with consul's address and management token:

```
$ vault write consul/config/access \
    address=http://127.0.0.1:4646 \
    token=adf4238a-882b-9ddc-4a9d-5b6758e4159e
Success! Data written to: consul/config/access
```

Vault secrets engines have the concept of roles, which are configuration units that group one or more Vault policies to a potential identity attribute, (e.g. LDAP Group membership). The name of the role is specified on the path, while the mapping to policies is done by naming them in a comma separated list, for example:

```
$ vault write consul/role/role-name policies=policyone,policytwo
Success! Data written to: consul/role/role-name
```

Similarly, to create management tokens, or global tokens:

```
$ vault write consul/role/role-name type=management global=true
```

```
Success! Data written to: consul/role/role-name
```

https://www.vaultproject.io/docs/secrets/consul

### Create Vault policy

Create a Vault policy to allow different identities to get tokens associated with a particular role:

```
$ cat << EOF | vault policy write consul-user-policy -
path "consul/creds/role-name" {
  capabilities = ["read"]
}
EOF
```

```
Policy 'consul-user-policy' written.
```

If you have an existing authentication backend (like LDAP), follow the relevant instructions to create a role available on the Authentication backends page. Otherwise, for testing purposes, a Vault token can be generated associated with the policy:

```
$ vault token create -policy=consul-user-policy
```

```
Key             Value
---             -----
token           deedfa83-99b5-34a1-278d-e8fb76809a5b
token_accessor  fd185371-7d80-8011-4f45-1bb3af2c2733
token_duration  768h0m0s
token_renewable true
token_policies  [default consul-user-policy]
```

### Obtain and test consul token

Finally obtain a consul Token using the existing Vault Token:

```
$ vault read consul/creds/role-name
```

```
Key             Value
---             -----
lease_id        consul/creds/role-name/6fb22e25-0cd1-b4c9-494e-aba330c317b9
lease_duration  768h0m0s
lease_renewable true
accessor_id     10b8fb49-7024-2126-8683-ab355b581db2
secret_id       8898d19c-e5b3-35e4-649e-4153d63fbea9
```

Verify that the token is created correctly in consul, looking it up by its accessor:

```
$ consul acl token info 10b8fb49-7024-2126-8683-ab355b581db2
```

```
Accessor ID  = 10b8fb49-7024-2126-8683-ab355b581db2
Secret ID    = 8898d19c-e5b3-35e4-649e-4153d63fbea9
Name         = Vault test root 1507307164169530060
Type         = management
Global       = true
Policies     = n/a
Create Time  = 2017-10-06 16:26:04.170633207 +0000 UTC
Create Index = 228
Modify Index = 228
```

Any user or process with access to Vault can now obtain short lived consul Tokens in order to carry out operations, thus centralizing the access to consul tokens.