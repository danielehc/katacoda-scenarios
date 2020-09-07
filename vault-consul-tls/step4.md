Once templates are created for the retrieval of the single
files, you can collect all the actions required by consul-template
to retrieve the certificates in one configuration file.

For this lab, you are going to use a template called `consul-template.hcl`{{open}}.

In it, you will define the following parameters to allow
`consul-template` to communicate with Vault:

* `address` : the address of your Vault server. In this lab, Vault runs on the same node as Consul so you can use `http://localhost:8200`.

* `token`  : a valid Vault ACL token with appropriate permissions. You will use Vault root token for this lab.

<div style="background-color:#eff5ff; color:#416f8c; border:1px solid #d0e0ff; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Info: </strong>

Earlier in the lab you used a root token to log in to Vault.
You will use that token in the next steps to generate
the TLS certs. This is not a best practice; the recommended security approach is to create
a new token based on a specific policy with limited privileges.

In this case the appropriate policy would have been the following.

```
path "pki_int/issue/consul-dc1" {
  capabilities = ["update"]
}
```

Read more on Vault authorization process in our [Vault Policies](https://learn.hashicorp.com/tutorials/vault/getting-started-policies) tutorial. 

</p></div>

Here is an example of the file you will create.

```
# This denotes the start of the configuration section for Vault. All values
# contained in this section pertain to Vault.
vault {
  # This is the address of the Vault leader. The protocol (http(s)) portion
  # of the address is required.
  address      = "<insert the address of your vault server here>"

  # This value can also be specified via the environment variable VAULT_TOKEN.
  token        = "<insert your token here>"

  # This should also be less than or around 1/3 of your TTL for a predictable
  # behaviour. Consult https://github.com/hashicorp/vault/issues/3414
  grace        = "1s"

  # This tells consul-template that the provided token is actually a wrapped
  # token that should be unwrapped using Vault's cubbyhole response wrapping
  # before being used. Consult Vault's cubbyhole response wrapping documentation
  # for more information.
  unwrap_token = false

  # This option tells consul-template to automatically renew the Vault token
  # given. If you are unfamiliar with Vault's architecture, Vault requires
  # tokens be renewed at some regular interval or they will be revoked. Consul
  # Template will automatically renew the token at half the lease duration of
  # the token. The default value is true, but this option can be disabled if
  # you want to renew the Vault token using an out-of-band process.
  renew_token  = true
}

# This block defines the configuration for connecting to a syslog server for
# logging.
syslog {
  enabled  = true

  # This is the name of the syslog facility to log to.
  facility = "LOCAL5"
}

# This block defines the configuration for a template. Unlike other blocks,
# this block may be specified multiple times to configure multiple templates.
template {
  # This is the source file on disk to use as the input template. This is often
  # called the "consul-template template".
  source      = "/opt/consul/templates/agent.crt.tpl"

  # This is the destination path on disk where the source template will render.
  # If the parent directories do not exist, consul-template will attempt to
  # create them, unless create_dest_dirs is false.
  destination = "/opt/consul/agent-certs/agent.crt"

  # This is the permission to render the file. If this option is left
  # unspecified, consul-template will attempt to match the permissions of the
  # file that already exists at the destination path. If no file exists at that
  # path, the permissions are 0644.
  perms       = 0700

  # This is the optional command to run when the template is rendered. The
  # command will only run if the resulting template changes.
  command     = "consul reload"
}

template {
  source      = "/opt/consul/templates/agent.key.tpl"
  destination = "/opt/consul/agent-certs/agent.key"
  perms       = 0700
  command     = "consul reload"
}

template {
  source      = "/opt/consul/templates/ca.crt.tpl"
  destination = "/opt/consul/agent-certs/ca.crt"
  command     = "consul reload"
}
```

### Start consul-template

After configuration is completed, you can start `consul-template`.
You must provide the file with the `-config` parameter.

`consul-template -config "consul_template.hcl"`{{execute T1}}

Verify the certificates are being correctly retrieved
by listing files in the destination directory:

`ls -l /opt/consul/agent-certs`{{execute T1}}


