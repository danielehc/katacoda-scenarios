The Consul service mesh in this lab is configured to have a pre-configured policy that denies all service communication.

You can check the initial intentions configuration on Consul UI intentions tab

For this tutorial you will define a default intention policy that denies all service communication.

You can check below the desired initial configuration you want to implement in your environment.

[Open Consul UI intentions tab](https://[[HOST_SUBDOMAIN]]-8500-[[KATACODA_HOST]].environments.katacoda.com/ui/dc1/intentions)

You should get a configuration similar to one in the following picture:

![intentions](consul-ui-intentions-deny-all-active.png)

### Verify service connectivity

[Open Web frontend UI from inside the node](https://[[HOST_SUBDOMAIN]]-9002-[[KATACODA_HOST]].environments.katacoda.com/ui)

![frontend fail](web-service-ui-fail.png)