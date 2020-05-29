

Consul ships with a built-in certification authority (CA) to reduce configuration friction.

`consul tls ca create`{{execute T1}}

The command creates two files `consul-agent-ca.pem` and `consul-agent-ca-key.pem` 

You can use the embedded editor to check the content of the files.

#### Create server certificate

Next step is to create a certificate for the server

`consul tls cert create -server`{{execute T1}}

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>
  In a production scenario it is recommended to create different certificates for each server.
</p></div>

