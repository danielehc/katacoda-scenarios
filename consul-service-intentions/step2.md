Consul 1.9 introduces the possibility to create intentions as configuration entries.

To make the _web_ service work properly you will need to define an intention that permits communication between service _web_ and service _api_.

The lab provides you a file, named `config-intentions-web.hcl`, with the following content:

```hcl
Kind = "service-intentions"
Name = "api"
Sources = [
  {
    Name   = "web"
    Action = "allow"
  },
  # NOTE: a default catch-all based on the default ACL policy will apply to
  # unmatched connections and requests. Typically this will be DENY.
]
```

This configuration entry defines an intention for service `api` allowing communication started from service `web`.

<div style="background-color:#eff5ff; color:#416f8c; border:1px solid #d0e0ff; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Info:</strong> This intention is not application aware and does not permit extra filtering on L7 attributes. These intentions are applicable to both tcp anf http service types. 
</p></div>

Once you reviewed the fle, apply the configuration with:

`consul config write config-intentions-api.hcl`{{execute}}

Example output:

```plaintext
Config entry written: service-intentions/api
```

### Verify intentions 

To verify the intentions in place in your Consul service mesh you can use the `connect/intentions` API endpoint:

`curl --silent  localhost:8500/v1/connect/intentions | jq`{{execute T1}}

Example output:

```json
[
  {
    "SourceNS": "default",
    "SourceName": "web",
    "DestinationNS": "default",
    "DestinationName": "api",
    "SourceType": "consul",
    "Action": "allow",
    "Precedence": 9,
    "CreateIndex": 445,
    "ModifyIndex": 445
  },
  {
    "SourceNS": "default",
    "SourceName": "*",
    "DestinationNS": "default",
    "DestinationName": "*",
    "SourceType": "consul",
    "Action": "deny",
    "Precedence": 5,
    "CreateIndex": 42,
    "ModifyIndex": 42
  }
]
```

