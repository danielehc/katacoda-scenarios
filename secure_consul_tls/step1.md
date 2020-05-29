
#### Initialize Consul buit-in CA

Initialize Consul built-in CA.

`consul tls ca create`{{execute operator}}

The command creates two files `consul-agent-ca.pem` and `consul-agent-ca-key.pem` 

You can use the embedded editor to check the content of the files.

#### Create server certificate

Next step is to create a certificate for the server

`consul tls cert create -server`{{execute operator}}


<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px; margin:24px 0; width:80%;">
  <p><strong>Warning: </strong>
  In a production scenario it is recommended to create different certificates for each server.

</p></div>

