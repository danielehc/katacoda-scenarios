
The Consul datacenter is configured to have ACL enabled so you will need a token
to perform operations.

During the deployment we saved the token into a configuration file 
`consul_env.conf`. This way you can setup the environment by sourcing the file
directly:

`source consul_env.conf`{{execute}}

#### View datacenter members

Once you have set the environment variables you can use `consul members` to
retrieve information on your datacenter.

`consul members`{{execute}}

You should receive an output similar to the following:

```screenshot
Node       Address          Status  Type    Build  Protocol  DC   Segment
server-1   172.19.0.3:8301  alive   server  1.9.3  2         dc1  <all>
cts-node   172.19.0.1:8301  alive   client  1.9.3  2         dc1  <default>
service-1  172.19.0.4:8301  alive   client  1.9.3  2         dc1  <default>
service-2  172.19.0.5:8301  alive   client  1.9.3  2         dc1  <default>
```

### View catalog services

Using the `catalog` command you can also list the services present in the Consul
catalog.

`consul catalog services -tags`{{execute T1}}

```snapshot
api                    v1
api-sidecar-proxy      v1
consul                 
web                    v1
web-sidecar-proxy      v1
```

You should get an output similar to the one above indicating the presence of
several services. Note the `v1` tag associated to some of the services. You
are going to use the tags later to filter among services for your network 
automation.

### Access Consul UI

Using the `Consul UI` tab you can also access the Consul UI for the datacenter.

To view all the content in the UI you will need to login using a token. You can 
use the master token for that.

`echo $CONSUL_HTTP_TOKEN`{{execute T1}}


### Provision [REMOVE]

`chmod +x provision_base.sh`{{execute T1}}

`./provision_base.sh`{{execute T1}}

## Install CTS

`curl -s https://releases.hashicorp.com/consul-terraform-sync/0.1.0-techpreview2/consul-terraform-sync_0.1.0-techpreview2_linux_amd64.zip -o consul-terraform-sync.zip`{{execute T1}}

`unzip consul-terraform-sync.zip`{{execute T1}}

`mv consul-terraform-sync /usr/local/bin/consul-terraform-sync`{{execute T1}}

`consul-terraform-sync -h`{{execute T1}}

## Configure CTS

## Start CTS

`consul-terraform-sync -config-file cts-config.hcl -inspect true`{{execute T1}}

`consul-terraform-sync -config-file cts-config.hcl -once`{{execute T1}}

`consul-terraform-sync -config-file cts-config.hcl`{{execute T1}}

## Check Files

## Change registration

`docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_HTTP_TOKEN}" \
  api sh -c "consul services register /assets/svc-api-tag.hcl"`{{execute T1}}

