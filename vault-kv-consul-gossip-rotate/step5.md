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

`sudo mkdir -p /opt/consul/templates`{{execute}}

### Configure template file

`gossip.key.tpl`{{open}}

`cp *.tpl /opt/consul/templates/`{{execute}}

### Start consul-template

After configuration is completed, you can start `consul-template`.
You must provide the file with the `-config` parameter.

`consul-template -config "consul_template.hcl"`{{execute}}

At this time you will have the gossip key saved in `/opt/consul/gossip/gossip.key`.

`cat /opt/consul/gossip/gossip.key`{{execute}}

Example output:

```
```

consul-template will automatically update the file every time the key is updated in Vault.

You can test this by generating a new key:

`vault kv put kv-v1/consul/config/encryption key=$(consul keygen)`{{execute}}

Example output:
```
Success! Data written to: kv-v1/consul/config/encryption
```

This will update the file: 

`cat /opt/consul/gossip/gossip.key`{{execute}}

Example output:

```
```




<!-- Primary keys -->
curl -s localhost:8500/v1/operator/keyring | jq -r '.[].PrimaryKeys| to_entries[].key'

<!-- All Keys -->
curl -s localhost:8500/v1/operator/keyring | jq -r '.[].Keys| to_entries[].key'

Sort and uniq and use the key retrieved as a value to grep -v