Once the server got a token assigned it is possible to create a token for the client node.

`consul acl policy create \
  -name consul-client \
  -rules @client_policy.hcl`{{execute T1}}

`consul acl token create \
  -description "consul-client agent token" \
  -policy-name consul-client | tee client.token`{{execute T1}}

### Configure Consul client

`export client_token=$(cat client.token | grep SecretID  | awk '{print $2}')`{{execute T1}}

`cat <<EOF >> ~/agent.hcl

acl = {
    enabled = true
    default_policy = "deny"
    enable_token_persistence = true
    tokens = {
        agent = "$(cat client.token | grep SecretID  | awk '{print $2}')"

    }
}
EOF
`{{execute T1}}

To configure clients you can embed the newly created token directly in the configuration file so that they will be able to use it right from startup. Add the token in the `agent.hcl`{{open}} file.



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
     -join=$(docker exec server consul members | grep server-1 | awk '{print $2}' | sed 's/:.*//g') \
     -config-file=/etc/consul.d/agent.hcl`{{execute T3}}
