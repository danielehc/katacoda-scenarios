You can use consul-template in your Consul datacenter to
integrate with Vault's KV Secrets Engine to dynamically rotate
you Consul gossip encryption keys.

### Create and populate the templates directory

This lab will demonstrate the gossip encryption rotation on a single server instance so that you can deploy a Consul datacenter that will automatically rotate the gossip encryption key based on updates in Vault.

You need to create templates that consul-template can use
to render the actual certificates and keys on the nodes in
your cluster. In this lab, you will place these templates
in `/opt/consul/templates`.

Create a directory called templates in `/opt/consul`.

`sudo mkdir -p /opt/consul/templates`{{execute T2}}

### 

The only data needed to 


### Server templates

As mentioned earlier, to configure mTLS for Consul servers you need the following files:

* `agent.crt` : Consul server node public certificate for the dc1 datacenter.
* `agent.key` : Consul server node private key for the dc1 datacenter.
* `ca.crt`    : CA public certificate.

You can instruct consul-template to generate and retrieve those files from Vault using the following templates:

`agent.crt.tpl`{{open}}

Example content:

```
{{ with secret "pki_int/issue/consul-dc1" "common_name=server.dc1.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.certificate }}
{{ end }}
```

`agent.key.tpl`{{open}}

Example content:

```
{{ with secret "pki_int/issue/consul-dc1" "common_name=server.dc1.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.private_key }}
{{ end }}
```

`ca.crt.tpl`{{open}}

Example content:

```
{{ with secret "pki_int/issue/consul-dc1" "common_name=server.dc1.consul" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}
```

### Consul CLI templates

The TLS certificates in the previous section will be used to
configure TLS encryption for your Consul datacenter. If you
need to use the Consul CLI on one of your agent nodes you should
consider generating different certificates only for CLI operations.

`cli.crt.tpl`{{open}}

Example content:

```
{{ with secret "pki_int/issue/consul-dc1" "ttl=24h" }}
{{ .Data.certificate }}
{{ end }}
```

`cli.key.tpl`{{open}}

Example content:

```
{{ with secret "pki_int/issue/consul-dc1" "ttl=24h" }}
{{ .Data.private_key }}
{{ end }}
```

Once you have reviewed the templates for consul-template,
you can copy the templates into `/opt/consul/templates`.

`cp *.tpl /opt/consul/templates/`{{execute T2}}

### Start consul-template

After configuration is completed, you can start `consul-template`.
You must provide the file with the `-config` parameter.

`consul-template -config "consul_template.hcl"`{{execute T2}}

Verify the certificates are being correctly retrieved
by listing files in the destination directory:

`ls -l /opt/consul/agent-certs`{{execute T3}}