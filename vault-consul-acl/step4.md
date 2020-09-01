
You can verify the Consul server started correctly by checking the logs.

`cat ~/log/consul.log`{{execute T1}}



`export CONSUL_SERVER_TOKEN=$(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}


Finally, you can apply the token to the server as its `agent` token.

`consul acl set-agent-token agent $(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}

You should receive the following output:

```plaintext
ACL token "agent" set successfully
```


<!-- Not sure if needed -->

`consul reload`{{execute T1}}