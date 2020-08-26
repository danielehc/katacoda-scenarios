


Reference Guide:
https://learn.hashicorp.com/tutorials/vault/deployment-guide?in=vault/day-one-consul


## Start Vault

`mkdir -p ~/log`{{execute T1}}

`nohup sh -c "vault server -dev -dev-root-token-id="root" -dev-listen-address=0.0.0.0:8200 >~/log/vault.log 2>&1" > ~/log/nohup.log &`{{execute T1}}

`export VAULT_ADDR='http://127.0.0.1:8200'`{{execute T1}}

`export VAULT_TOKEN="root"`{{execute T1}}


> This is not needed for this lab but it might be a valid point to make in the tutorial
> https://learn.hashicorp.com/tutorials/vault/pki-engine
>
> `vault policy write consul vault_provisioner_policy.hcl`{{execute T1}}







