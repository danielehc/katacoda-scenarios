#### Configure port forwarding for your frontend application

To access the app running inside your COnsul service mesh you will setup a port forwarding.

`export IP_ADDR=$(hostname -I | awk '{print $1}')`{{execute}}

`kubectl port-forward service/web 9090:9090 --address ${IP_ADDR}`{{execute}}

This will forward port `9090` of `service/web` on port `9090` of your test machine.

You can now open the [Dashboard]([Consul UI](https://[[HOST_SUBDOMAIN]]-9090-[[KATACODA_HOST]].environments.katacoda.com/ui)) tab to be redirected to the web application UI.