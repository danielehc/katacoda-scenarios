
### Generate consul gossip key

https://learn.hashicorp.com/tutorials/nomad/security-gossip-encryption#generate-an-encryption-key

* **Method 1: consul binary** 

The lab includes a Consul binary on the same Virtual Machine that will be used to test Consul gossip encryption. The `consul` binary can be used to generate a valid gossip encryption key:

`consul keygen`{{execute T1}}

<div style="background-color:#eff5ff; color:#416f8c; border:1px solid #d0e0ff; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Info: </strong>

Alternatively, you can use any method that can create 16 random bytes encoded in base64.
<br/>

<ul>
<li>
* **Method 2: openssl** <br/>
`openssl rand -base64 16`{{execute T1}}
</li>
<li>
* **Method 3: dd** <br/>
`dd if=/dev/urandom bs=16 count=1 status=none | base64`{{execute T1}}
</li>
<ul>
</p></div>








https://learn.hashicorp.com/tutorials/vault/static-secrets

https://learn.hashicorp.com/tutorials/nomad/vault-nomad-secrets?in=nomad/access-control

https://www.vaultproject.io/docs/secrets/consul

### Enable Vault secrets engine

`vault secrets list -detailed`{{execute T1}}

`vault secrets enable -path="kv-v1" kv`{{execute T1}}

Example output:

```
Success! Enabled the kv secrets engine at: kv-v1/
```

### Write encryption key in Vault

`vault kv put kv-v1/consul/config/encryption key=cg8StVXbQJ0gPvMd9o7yrg==`{{execute T1}}

Example output:
```
Success! Data written to: kv-v1/consul/config/encryption
```

`vault kv get -field=key kv-v1/consul/config/encryption`{{execute T1}}
