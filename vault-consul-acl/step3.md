
### Obtain and test consul token

Next, obtain a Consul token using the existing Vault token:

`vault read consul/creds/consul-server-role | tee consul.server`{{execute T1}}

Example output:

```
Key                Value
---                -----
lease_id           consul/creds/consul-server-role/bHDVG24vCO8BJ90ONjxrbKP6
lease_duration     768h
lease_renewable    true
accessor           2b9bb86a-d632-ea28-3890-7d1e0690ff57
local              false
token              5ea5eadc-807d-68c2-e47f-a1ac37e906b7
```

`export CONSUL_SERVER_ACCESSOR=$(cat consul.server  | grep accessor  | awk '{print $2}')`{{execute T1}}

Verify that the token is created correctly in Consul by
looking it up by its accessor:

`consul acl token read -id ${CONSUL_SERVER_ACCESSOR}`{{execute T1}}

```
AccessorID:       2b9bb86a-d632-ea28-3890-7d1e0690ff57
SecretID:         5ea5eadc-807d-68c2-e47f-a1ac37e906b7
Description:      Vault consul-server-role token 1598547759570180867
Local:            false
Create Time:      2020-08-27 17:02:39.572006543 +0000 UTC
Policies:
   6fa2c574-6951-51db-310a-672e328f2aba - consul-servers
```

Any user or process with access to Vault can now obtain
short lived Consul tokens in order to carry out operations,
thus centralizing the access to Consul tokens.
