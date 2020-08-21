## Start Vault

```
mkdir -p ~/log
```

```
nohup sh -c "vault server -dev -dev-root-token-id="root" -dev-listen-address=0.0.0.0:8200 >~/log/vault.log 2>&1" > ~/log/nohup.log &
```

```
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="root"
```