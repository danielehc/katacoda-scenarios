


Reference Guide:

https://learn.hashicorp.com/tutorials/vault/pki-engine
https://learn.hashicorp.com/tutorials/vault/deployment-guide?in=vault/day-one-consul

## Start Vault

`mkdir -p ~/log`{{execute T1}}

`nohup sh -c "vault server -dev -dev-root-token-id="root" -dev-listen-address=0.0.0.0:8200 >~/log/vault.log 2>&1" > ~/log/nohup.log &`{{execute T1}}

`export VAULT_ADDR='http://127.0.0.1:8200'`{{execute T1}}

`export VAULT_TOKEN="root"`{{execute T1}}


`vault policy write consul vault_provisioner_policy.hcl`{{execute T1}}


## Generate Root CA

`vault secrets enable pki`{{execute T1}}

`vault secrets tune -max-lease-ttl=87600h pki`{{execute T1}}


`vault write -field=certificate pki/root/generate/internal \
        common_name="dc1.consul" \
        ttl=87600h > CA_cert.crt`{{execute T1}}


`vault write pki/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"`{{execute T1}}

## Generate Intermediate CA

`vault secrets enable -path=pki_int pki`{{execute T1}}

`vault secrets tune -max-lease-ttl=43800h pki_int`{{execute T1}}

`vault write -format=json pki_int/intermediate/generate/internal \
        common_name="dc1.consul Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr`{{execute T1}}

`vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem`{{execute T1}}

`vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem`{{execute T1}}


## Create a Role

`vault write pki_int/roles/consul \
        allowed_domains="dc1.consul" \
        allow_subdomains=true \
        max_ttl="720h"`{{execute T1}}

## Generate Certificate

`vault write pki_int/issue/consul common_name="server.dc1.consul" ttl="24h"`{{execute T1}}




