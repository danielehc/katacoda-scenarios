
#### Initialize Consul buit-in CA

Initialize Consul built-in CA.

`consul tls ca create`{{execute operator}}

The command creates two files `consul-agent-ca.pem` and `consul-agent-ca-key.pem` 

You can use the embedded editor to check the content of the files.

#### Create server certificate

Next step is to create a certificate for the server

`consul tls cert create -server`{{execute operator}}


<p class="callout info">A success message</p>
<p class="callout success">A success message</p>
<p class="callout warning">A success message</p>
<p class="callout danger">A success message</p>

