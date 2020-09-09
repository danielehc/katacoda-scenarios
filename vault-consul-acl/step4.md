
You can verify the Consul server started correctly by checking the logs.

`cat ~/log/consul.log`{{execute T1}}

In the logs you should get some warning lines similar to the following:

```
[WARN]  agent: Coordinate update blocked by ACLs: accessorID=00000000-0000-0000-0000-000000000002
[WARN]  agent: Node info update blocked by ACLs: node=6e24f8cd-33b5-645a-a2b3-b332e59e9f84 accessorID=00000000-0000-0000-0000-000000000002
```

These warnings signal that Consul started properly but it cannot communicate with the rest of the datacenter because of ACL restrictions.

### Apply token to Consul server

For this lab you saved the token inside the `consul.server` file.

You can retrieve it and store it in an environment variable.

`export CONSUL_SERVER_TOKEN=$(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}

<div style="background-color:#eff5ff; color:#416f8c; border:1px solid #d0e0ff; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Info: </strong>

<!-- Suggestion
I think it would be good to note in this step the relation between accessorId/secretID/token for Consul and Vault. Do they map to each other? Also we should note that the secretID for Consul is how you refer to the token on the cli/api and in files.
-->
The way Vault and Consul refer to tokens in the command output is slightly different. The following table expresses the relations between the two outputs:
<br/>

<table style="width:auto">
  <tr>
    <th>Consul</th>
    <th>Vault</th> 
    <th>Meaning</th>
  </tr>
  <tr>
    <td>`AccessorID`</td>
    <td>`accessor`</td>
    <td>The unique identifier for the token inside Consul and Vault.</td>
  </tr>
  <tr>
    <td>`SecretID`</td>
    <td>`token`</td>
    <td>The actual token to be used for configuration and operations.</td>
  </tr>
</table>

Using Consul secrets engine with Vault ensures that these values are kept consistent when the tokens are replicated to Consul.

</p></div>

Finally, you can apply the token to the server as its `agent` token.

`consul acl set-agent-token agent $(cat consul.server  | grep token  | awk '{print $2}')`{{execute T1}}

You should receive the following output:

```plaintext
ACL token "agent" set successfully
```

Once the token is applied you can check once more the Consul logs and verify that the warning lines are not being logged anymore.

`cat ~/log/consul.log`{{execute T1}}

```
...
[INFO]  agent: Updated agent's ACL token: token=agent
[INFO]  agent: Synced node info
```

<!-- Not sure if needed 

`consul reload`{{execute T1}}

-->