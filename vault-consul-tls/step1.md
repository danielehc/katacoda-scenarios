Create a policy to access the role endpoint

Create a policy file named tls-policy.hcl and provide it the following contents.

```
path "pki_int/issue/consul-datacenter" {
  capabilities = ["update"]
}
```

Write the policy you just created into Vault.

`vault policy write tls-policy tls-policy.hcl`{{execute T1}}

```
Success! Uploaded policy: tls-policy
```

### Configure consul-template

Generate a token based on tls-policy

`vault token create -policy="tls-policy" -period=24h -orphan`{{execute T1}}

Make a note of this token as you will need it in the upcoming steps.

### Create and populate the templates directory

You need to create templates that consul-template can use to render the actual certificates and keys on the nodes in our cluster. In this lab, you will place these templates in `/opt/consul/templates`.

Create a directory called templates in `/opt/consul`.

`sudo mkdir /opt/consul/templates`{{execute T1}}

You will provide different templates to the nodes depending on whether they are server nodes or client nodes. All of the nodes will get the CLI templates (since you want to use the CLI on any of the nodes).

agent.crt.tpl.

```
{{ with secret "pki_int/issue/consul-datacenter" "common_name=server.dc1.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.certificate }}
{{ end }}
```

agent.key.tpl.

```
{{ with secret "pki_int/issue/consul-datacenter" "common_name=server.dc1.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.private_key }}
{{ end }}
```

ca.crt.tpl.

```
{{ with secret "pki_int/issue/consul-datacenter" "common_name=server.dc1.consul" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}
```