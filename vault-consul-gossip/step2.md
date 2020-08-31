Once the key is stored into Vault you can retrieve it from any machine that has access to Vault.

From your Consul server node, use the `vault kv get` command using the `-field` parameter to retrieve the key value only.

`vault kv get -field=key kv-v1/consul/config/encryption`{{execute T1}}

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>

  The command relies on the presence, in your environment variables, of `VAULT_ADDR` and `VAULT_TOKEN` to define Vault address and user token respectively. In this scenario these variables were defined right after the Vault process started with:
  * `export VAULT_ADDR='http://127.0.0.1:8200'`
  * `export VAULT_TOKEN="root"`

  If you want to apply this scenario to your own dev environment you will have a dedicated node for Vault and you will want to modify the `VAULT_ADDR` variable to reflect the actual address of your Vault cluster.

  Same principle applies to the `VAULT_TOKEN` that will have to contain a valid token for your Vault instance.

</p></div>





