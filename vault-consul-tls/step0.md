


Reference Guide:
https://learn.hashicorp.com/tutorials/vault/deployment-guide?in=vault/day-one-consul


## Start Vault

`mkdir -p ~/log`{{execute T1}}

`nohup sh -c "vault server -dev -dev-root-token-id="root" -dev-listen-address=0.0.0.0:8200 >~/log/vault.log 2>&1" > ~/log/nohup.log &`{{execute T1}}

`export VAULT_ADDR='http://127.0.0.1:8200'`{{execute T1}}

`export VAULT_TOKEN="root"`{{execute T1}}


> This is not needed for this lab but it might be a valid point to make in the tutorial
> https://learn.hashicorp.com/tutorials/vault/pki-engine

`vault policy write consul vault_provisioner_policy.hcl`{{execute T1}}


## Generate Root CA

First, enable the `pki` secrets engine at the `pki` path.

`vault secrets enable pki`{{execute T1}}

Tune the `pki` secrets engine to issue certificates with a maximum time-to-live (TTL) of 87600 hours.

`vault secrets tune -max-lease-ttl=87600h pki`{{execute T1}}

Generate the root certificate and save the certificate in `CA_cert.crt`.

`vault write -field=certificate pki/root/generate/internal \
        common_name="dc1.consul" \
        ttl=87600h > CA_cert.crt`{{execute T1}}

This generates a new self-signed CA certificate and private key. 
Vault will automatically revoke the generated root at the end of its lease period (TTL); 
the CA certificate will sign its own Certificate Revocation List (CRL).

Configure the CA and CRL URLs.

`vault write pki/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"`{{execute T1}}

## Generate Intermediate CA

First, enable the `pki` secrets engine at the `pki_int` path.

`vault secrets enable -path=pki_int pki`{{execute T1}}

Tune the `pki_int` secrets engine to issue certificates with a maximum time-to-live (TTL) of 43800 hours.

`vault secrets tune -max-lease-ttl=43800h pki_int`{{execute T1}}

Request an intermediate certificate and save the CSR as `pki_intermediate.csr`.

`vault write -format=json pki_int/intermediate/generate/internal \
        common_name="dc1.consul Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr`{{execute T1}}

Once the CSR is signed and the root CA returns a certificate, it can be imported back into Vault.

`vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem`{{execute T1}}

`vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem`{{execute T1}}


## Create a Role

A role is a logical name that maps to a policy used to generate those credentials. 

`vault write pki_int/roles/consul-dc1 \
        allowed_domains="dc1.consul" \
        allow_subdomains=true \
        generate_lease=true \
        max_ttl="720h"`{{execute T1}}

For this lab you are using the following options for the role:

* `allowed_domains` :  Specifies the domains of the role. The command uses `dc1.consul` as domain being the default configuration you are going to use for Consul.
* `allow_subdomains` : Specifies if clients can request certificates with CNs that are subdomains of the CNs allowed by the other role options (NOTE: This includes wildcard subdomains.)
* `generate_lease` :   Specifies if certificates issued/signed against this role will have Vault leases attached to them. Certificates can be added to the CRL by vault revoke <lease_id> when certificates are associated with leases. 

This completes the Vault configuration as a CA. Move to next step to generate certificates.

## Generate Certificate

You can test the `pki` engine by generating a first certificate.

`vault write pki_int/issue/consul-dc1 common_name="server.dc1.consul" ttl="24h"`{{execute T1}}




