
Consul uses Access Control Lists (ACLs) to secure the UI, API, CLI, service communications, and agent communications. When securing your datacenter you should configure the ACLs first. 

Open `agent.hcl`{{open}} in the editor to inspect values required for a minimal configuration with ACL system enabled.

```
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
```

In this example, you will configure the default policy of "deny", which means all operations will not be permitted unless made using a token that permits them. 

By enabling token persistence, tokens will be persisted to disk and reloaded when an agent restarts.

#### Distribute configuration

This scenario uses two Docker volumes, called `server_config` and `client_config` to help you distribute the configuration to your agents.

`docker cp ./agent.hcl volumes:/server/agent.hcl`{{execute T2}}

`docker cp ./agent.hcl volumes:/client/agent.hcl`{{execute T3}}
