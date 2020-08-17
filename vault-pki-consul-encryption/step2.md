Reference Guide:

https://learn.hashicorp.com/tutorials/vault/pki-engine
https://learn.hashicorp.com/tutorials/vault/deployment-guide?in=vault/day-one-consul


mkdir -p ~/log
nohup sh -c "vault server -dev -dev-root-token-id="root" -dev-listen-address=0.0.0.0:8200 >~/log/vault.log 2>&1" > ~/log/nohup.log &

If you use another terminal, you need to set the following environment variables:

export VAULT_ADDR='http://127.0.0.1:8200'
Root Token: s.xpL4rUy2KP0qLd4gqq46Pki4

Followed the PKI guide to build your own CA
made sure dc1.consul was the common name

Commands I ran to create a CA and server certificate:

```
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="s.5msDhDmcx9LsFVALp4SOmhQ8"
vault policy write consul acl-policy.hcl
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \\n        common_name="dc1.consul" \\n        ttl=87600h > CA_cert.crt\n
vault write pki/config/urls \\n        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \\n        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"\n
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
vault write -format=json pki_int/intermediate/generate/internal \\n        common_name="dc1.consul Intermediate Authority" \\n        | jq -r '.data.csr' > pki_intermediate.csr\n
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \\n        format=pem_bundle ttl="43800h" \\n        | jq -r '.data.certificate' > intermediate.cert.pem\n
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
vault write pki_int/roles/consul \\n        allowed_domains="dc1.consul" \\n        allow_subdomains=true \\n        max_ttl="720h"\n
vault write pki_int/issue/consul common_name="server.dc1.consul" ttl="24h"
```