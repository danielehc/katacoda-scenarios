#### Configure port forwarding for your frontend application

To access the app running inside your COnsul service mesh you will setup a port forwarding.

`export IP_ADDR=$(hostname -I | awk '{print $1}')`{{execute}}

`kubectl port-forward service/web 9090:9090 --address ${IP_ADDR}`{{execute}}

This will forward port `80` of `service/hashicorp-consul-ui` on port `80` of your test machine.

You can now open the Consul UI tab to be redirected to the Consul UI.