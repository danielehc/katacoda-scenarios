
You can now use the bootstrap token to create other ACL policies for the rest of your datacenter.

The first policy you are going to create is the one for the server.

`consul acl policy create \
  -name consul-server-one \
  -rules @server_policy.hcl`{{execute T1}}

`consul acl token create \
  -description "consul-server-1 agent token" \
  -policy-name consul-server-one`{{execute T1}}

consul acl set-agent-token agent "<agent token here>"
