
Once configuration is distributed on the nodes it is possible to start the Consul server.

`docker run \
    -d \
    -v server_config:/etc/consul.d \
    -p 8500:8500 \
    -p 8600:8600/udp \
    --name=server \
    consul agent -server -ui \
     -node=server-1 \
     -bootstrap-expect=1 \
     -client=0.0.0.0 \
     -config-file=/etc/consul.d/agent.hcl`{{execute T2}}

### Check server logs

You can verify the Consul server started correctly by checking the logs.

`docker logs server`{{execute T2}}

Alternatively you can reach the [Consul UI](https://[[HOST_SUBDOMAIN]]-8500-[[KATACODA_HOST]].environments.katacoda.com/ui) tab to be redirected to the Consul UI.

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>
  The current configuration leaves the HTTP interface open for the UI so to permit you to access it without setting a client certificate for your browser. To complete configuration and prevent the UOI to be accessed over HTTP you can add the following to your server configuration:<br>
  ```
  "ports": {
    "http": -1,
    "https": 8501
  }
  ```
</p></div>
