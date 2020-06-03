Once the server got a token assigned it is possible to create a token for the client node.

`consul acl policy create \
  -name consul-client \
  -rules @client_policy.hcl`{{execute T1}}

`consul acl token create \
  -description "consul-client agent token" \
  -policy-name consul-client | tee client.token`{{execute T1}}


### Configure Consul client

consul acl set-agent-token agent "<agent token here>"

To configure clients you can embed the newly created token directly in the configuration file so that they will be able to use it right from startup. Add the token in the `agent.hcl`{{open}} file.

<pre class="file" data-filename="agent.hcl" data-target="insert" data-marker="        agent =">
        agent = "${client_token}"
</pre>

Once the file is modified to include the token distribute it to the client.

`docker cp ./agent.hcl volumes:/client/agent.hcl`{{execute T3}}

### Start Consul client

Finally start the Consul client.

`docker run \
    -d \
    -v client_config:/etc/consul.d \
    --name=client \
    consul agent \
     -node=client-1 \
     -join=${CONSUL_HTTP_ADDR} \
     -config-file=/etc/consul.d/client.json`{{execute T3}}
