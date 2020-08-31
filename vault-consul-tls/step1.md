Vault's PKI secrets engine can dynamically generate X.509 certificates on demand. This allows services to acquire certificates without going through the usual manual process of generating a private key and Certificate Signing Request (CSR), submitting to a CA, and then waiting for the verification and signing process to complete.

First, enable the `pki` secrets engine at the `pki` path.

`vault secrets enable pki`{{execute T1}}

```
Success! Enabled the pki secrets engine at: pki/
```

Tune the `pki` secrets engine to issue certificates with a maximum time-to-live (TTL) of 87600 hours.

`vault secrets tune -max-lease-ttl=87600h pki`{{execute T1}}

```
Success! Tuned the secrets engine at: pki/`
```

### Generate Root CA

Generate the root certificate and save the certificate in `CA_cert.crt`.

`vault write -field=certificate pki/root/generate/internal \
        common_name="dc1.consul" \
        ttl=87600h > CA_cert.crt`{{execute T1}}

This generates a new self-signed CA certificate and private key. 
Vault will automatically revoke the generated root at the end of its lease period (TTL); 
the CA certificate will sign its own Certificate Revocation List (CRL).

> If you want you can inspect the certificate created using the `openssl` tool:
> `openssl x509 -text -noout -in CA_cert.crt`{{execute T1}}

Configure the CA and CRL URLs.

`vault write pki/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"`{{execute T1}}

```
Success! Data written to: pki/config/urls
```

## Generate Intermediate CA

First, enable the `pki` secrets engine at the `pki_int` path.

`vault secrets enable -path=pki_int pki`{{execute T1}}

```
Success! Enabled the pki secrets engine at: pki_int/
```

Tune the `pki_int` secrets engine to issue certificates with a maximum time-to-live (TTL) of 43800 hours.

`vault secrets tune -max-lease-ttl=43800h pki_int`{{execute T1}}

```
Success! Tuned the secrets engine at: pki_int/
```

Request an intermediate certificate and save the CSR as `pki_intermediate.csr`.

`vault write -format=json pki_int/intermediate/generate/internal \
        common_name="dc1.consul Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr`{{execute T1}}

Sign the CSR.

`vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem`{{execute T1}}

Once the CSR is signed and the root CA returns a certificate, it can be imported back into Vault.

`vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem`{{execute T1}}

```
Success! Data written to: pki_int/intermediate/set-signed
```

## Create a Role

A role is a logical name that maps to a policy used to generate those credentials. 

`vault write pki_int/roles/consul-dc1 \
        allowed_domains="dc1.consul" \
        allow_subdomains=true \
        generate_lease=true \
        max_ttl="720h"`{{execute T1}}

```
Success! Data written to: pki_int/roles/consul-dc1
```

For this lab you are using the following options for the role:

* `allowed_domains` :  Specifies the domains of the role. The command uses `dc1.consul` as domain being the default configuration you are going to use for Consul.
* `allow_subdomains` : Specifies if clients can request certificates with CNs that are subdomains of the CNs allowed by the other role options (NOTE: This includes wildcard subdomains.)
* `generate_lease` :   Specifies if certificates issued/signed against this role will have Vault leases attached to them. Certificates can be added to the CRL by vault revoke <lease_id> when certificates are associated with leases. 

This completes the Vault configuration as a CA. Move to next step to generate certificates.

## Generate First Server Certificate

You can test the `pki` engine by generating a first certificate.

`vault write pki_int/issue/consul-dc1 common_name="server.dc1.consul" ttl="24h"`{{execute T1}}

### Create a policy to access the role endpoint

Earlier in the lab you used a root token to log in to Vault. Although you could use that token in our next steps to generate our TLS certs, the recommended security approach is to create a new token based on a specific policy with limited privileges.

Create a policy file named `tls-policy.hcl` and provide it the following contents.

```
path "pki_int/issue/consul-dc1" {
  capabilities = ["update"]
}
```

Write the policy you created into Vault.

`vault policy write tls-policy tls-policy.hcl`{{execute T1}}

```
Success! Uploaded policy: tls-policy
```

