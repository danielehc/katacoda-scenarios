
You can verify the Consul server started correctly by checking the logs.

`cat ~/log/consul.log`{{execute T1}}



`export CONSUL_SERVER_TOKEN=$(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}


Finally, you can apply the token to the server as its `agent` token.


<!-- Suggestion
I think it would be good to note in this step the relation between accessorId/secretID/token for Consul and Vault. Do they map to each other? Also we should note that the secretID for Consul is how you refer to the token on the cli/api and in files.
-->


`consul acl set-agent-token agent $(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}

You should receive the following output:

```plaintext
ACL token "agent" set successfully
```


<!-- Not sure if needed -->

`consul reload`{{execute T1}}
