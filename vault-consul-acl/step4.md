
You can verify the Consul server started correctly by checking the logs.

`cat ~/log/consul.log`{{execute T1}}



`export CONSUL_SERVER_TOKEN=$(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}


Finally you can apply the token to the server as its `agent` token.

`consul acl set-agent-token agent $(cat server.token  | grep SecretID  | awk '{print $2}')`{{execute T1}}

You should receive the following output:

```plaintext
ACL token "agent" set successfully
```



## REMOVE AFTER THIS

--- 

### Check Consul state

* There is no Service registered because the node has no agent token
* 

`consul acl token create \
  -description "consul-server-1 agent token" \
  -policy-name consul-server-one | tee server.token`{{execute T1}}

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>
  In this hands-on lab, you are redirecting the output of the `consul acl token create` command to a file to simplify operations in the next steps. In a real-life scenario, you want to make sure the token is stored in a safe place. If it is compromised, the ACL system can be abused.
</p></div>

Finally you can apply the token to the server as its `agent` token.

`consul acl set-agent-token agent $(cat server.token  | grep SecretID  | awk '{print $2}')`{{execute T1}}

You should receive the following output:

```plaintext
ACL token "agent" set successfully
```