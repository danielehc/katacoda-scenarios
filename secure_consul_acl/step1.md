
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

This scenario uses a Docker volumes, called `server_config` to help you distribute the configuration to your server.

`docker cp ./agent.hcl volumes:/server/server.hcl`{{execute T2}}

### Start Consul server

Once configuration is distributed on the nodes it is possible to start the Consul server.

`docker run \
    -d \
    -v server_config:/etc/consul.d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui \
     -node=server-1 \
     -bootstrap-expect=1 \
     -client=0.0.0.0 \
     -config-file=/etc/consul.d/agent.hcl`{{execute T2}}

### Check server logs

You can verify the Consul server started correctly by checking the logs.

`docker logs server`{{execute T2}}

You should get a log message like the following when ACLs are enabled:

`agent.server: initializing acls`

Alternatively you can reach the [Consul UI](https://[[HOST_SUBDOMAIN]]-8500-[[KATACODA_HOST]].environments.katacoda.com/ui) tab to be redirected to the Consul UI.

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>
  Like any other requests made by Consul once ACLs are enabled, the results showed by the UI are the ones available by default to all unauthenticated (anonymous) clients. At this time your first inspection of the UI will show only empty tabs (no services, nor nodes). You will apply a token to access those info from the UI later in this lab.
</p></div>