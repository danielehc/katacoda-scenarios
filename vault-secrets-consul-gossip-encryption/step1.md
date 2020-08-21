
### Generate consul gossip key

https://learn.hashicorp.com/tutorials/nomad/security-gossip-encryption#generate-an-encryption-key

```
consul keygen
```

Alternatively, you can use any method that can create 16 random bytes encoded in base64.

```
$ openssl rand -base64 16 
VNYxXf/MuX49lgS6F34Vzw==
```

```
$ dd if=/dev/urandom bs=16 count=1 status=none | base64
LsuYyj93KVfT3pAJPMMCgA==
```

https://learn.hashicorp.com/tutorials/vault/static-secrets

https://learn.hashicorp.com/tutorials/nomad/vault-nomad-secrets?in=nomad/access-control

https://www.vaultproject.io/docs/secrets/consul

### Enable Vault secrets engine

```
vault secrets list -detailed
```

```
vault secrets enable -path="kv-v1" kv
```

### Write encryption key in Vault

```
vault kv put kv-v1/consul/config/encryption key=cg8StVXbQJ0gPvMd9o7yrg==
Success! Data written to: kv-v1/consul/config/encryption
```

```
vault kv get -field=key kv-v1/consul/config/encryption
```
