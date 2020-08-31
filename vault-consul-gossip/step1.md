For this lab you are going to use Vault kv secrets engine.

First, you are going to enable a new secret engine, called `kv` at path `kv-v1`

`vault secrets enable -path="kv-v1" kv`{{execute T1}}

Example output:

```
Success! Enabled the kv secrets engine at: kv-v1/
```

Once the secret engine is enabled you will be able to verify this using the following command:

`vault secrets list -detailed`{{execute T1}}

### Generate consul gossip key

Once you enabled Vault secrets engine you can now generate the COnsul gossip encryption key.

There are multiple ways to generate a valid gossip encryption key:

* **Method 1: consul binary** 

The lab includes a Consul binary on the same Virtual Machine that will be used to test Consul gossip encryption. The `consul` binary can be used to generate a valid gossip encryption key:

`export CONSUL_GOSSIP_KEY=$(consul keygen)`{{execute T1}}

<div style="background-color:#eff5ff; color:#416f8c; border:1px solid #d0e0ff; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Info: </strong>

Alternatively, you can use any method that can create 16 random bytes encoded in base64.
<br/>

<ul>
<li>
* **Method 2: openssl** - `openssl rand -base64 16`
</li>
<li>
* **Method 3: dd** - `dd if=/dev/urandom bs=16 count=1 status=none | base64`
</li>
</ul>

If you decide to use one of these methods for the lab make sure you use the `CONSUL_GOSSIP_KEY` variable to store the result of the command or to take note of the value of the key generated to manually enter it into Consul's configuration file later.

</p></div>

### Write encryption key in Vault

`vault kv put kv-v1/consul/config/encryption key=${CONSUL_GOSSIP_KEY}`{{execute T1}}

Example output:
```
Success! Data written to: kv-v1/consul/config/encryption
```
