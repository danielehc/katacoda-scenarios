
`git clone https://github.com/hashicorp/consul-helm.git`{{execute}}

`cd consul-helm`{{execute}}

`git checkout wan-federation-base`{{execute}}

`cd ..`{{execute}}

`export KUBECONFIG=${HOME}/.shipyard/config/dc1/kubeconfig.yaml`{{execute}}

`helm install consul ./consul-helm -f ./dc1-values.yml --timeout 10m`{{execute}}

`kubectl get pods --all-namespaces`{{execute}}

```
NAME                                                          READY   STATUS    RESTARTS   AGE
consul-connect-injector-webhook-deployment-6fd55dfcd7-5jxnm   1/1     Running   0          50s
consul-server-0                                               1/1     Running   0          49s
consul-5642w                                                  1/1     Running   0          50s
consul-mesh-gateway-bc7f449cb-7hxt6                           1/1     Running   3          50s
```


`kubectl get svc consul-mesh-gateway`{{execute}}

```
NAME                  TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)         AGE
consul-mesh-gateway   LoadBalancer   10.0.202.79   20.185.102.21   443:32753/TCP   108s
```

Once it has it, update meshGateway.wanAddress.host to that IP in your dc1-config.yaml file. In this example it would look like
```
meshGateway:
  wanAddress:
    useNodeIP: false
    host: "20.185.102.21"
```

`kubectl get secret consul-ca-cert -o yaml > consul-ca-cert.yaml`{{execute}}
`kubectl get secret consul-ca-key -o yaml > consul-ca-key.yaml`{{execute}}


`export KUBECONFIG=${HOME}/.shipyard/config/dc2/kubeconfig.yaml`{{execute}}

`kubectl create -f consul-ca-cert.yaml -f consul-ca-key.yaml`{{execute}}

`helm install consul ./consul-helm -f ./dc2-values.yml --timeout 10m`{{execute}}

`export KUBECONFIG=${HOME}/.shipyard/config/dc1/kubeconfig.yaml`{{execute}}

`kubectl apply -f ~/api.yml`{{execute}}


`export KUBECONFIG=${HOME}/.shipyard/config/dc2/kubeconfig.yaml`{{execute}}

`kubectl apply -f ~/web.yml`{{execute}}

`export IP_ADDR=$(hostname -I | awk '{print $1}')`{{execute}}

`kubectl port-forward service/web 9090:9090 --address ${IP_ADDR}`{{execute}}