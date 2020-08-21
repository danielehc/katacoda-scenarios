


Reference Guide:

https://learn.hashicorp.com/tutorials/vault/pki-engine
https://learn.hashicorp.com/tutorials/vault/deployment-guide?in=vault/day-one-consul

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

```
vault policy write consul vault_provisioner_policy.hcl
```

## Generate Root CA

```
vault secrets enable pki
```

```
vault secrets tune -max-lease-ttl=87600h pki
```

```
vault write -field=certificate pki/root/generate/internal \
        common_name="dc1.consul" \
        ttl=87600h > CA_cert.crt
```

```
vault write pki/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
```

## Generate Intermediate CA

```
vault secrets enable -path=pki_int pki
```

```
vault secrets tune -max-lease-ttl=43800h pki_int
```

```
vault write -format=json pki_int/intermediate/generate/internal \
        common_name="dc1.consul Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr
```

```
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem
```

```
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
```

## Create a Role

```
vault write pki_int/roles/consul \
        allowed_domains="dc1.consul" \
        allow_subdomains=true \
        max_ttl="720h"
```

## Generate Certificate

```
vault write pki_int/issue/consul common_name="server.dc1.consul" ttl="24h"
```



