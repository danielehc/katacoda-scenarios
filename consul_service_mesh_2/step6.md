#### Configure port forwarding for your frontend service

To access the app running inside your Consul service mesh, you will setup port forwarding.

`export IP_ADDR=$(hostname -I | awk '{print $1}')`{{execute}}

`kubectl port-forward service/web 9090:9090 --address ${IP_ADDR}`{{execute}}

This will forward port `80` of `service/hashicorp-consul-ui` on port `80` of your test machine.
