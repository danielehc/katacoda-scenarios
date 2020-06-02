#### Wait until all pods are running

Before being able to access Consul you need to verify the deploy was completed.

`kubectl get pods --all-namespaces`{{execute}}

If the output shows all the pods in a `Running` state you can now configure your Kubernetes cluster to be accessed from outside.

#### Configure port forwarding for your Consul UI

To access Consul UI you will setup port forwarding.

`export IP_ADDR=$(hostname -I | awk '{print $1}')`{{execute}}

`kubectl port-forward service/hashicorp-consul-ui 80:80 --address ${IP_ADDR}`{{execute}}

This will forward port `80` of `service/hashicorp-consul-ui` on port `80` of your test machine.

You can now open the Consul UI tab to be redirected to the Consul UI. The Consul UI will list
the `consul` service. 




