Minikube has been installed and configured in the environment. Check that it is properly installed, by running the minikube version command:

`minikube version`{{execute}}

#### Start the cluster, by running the minikube start command:

`minikube start`{{execute}}

Great! You now have a running Kubernetes cluster in your online terminal. Minikube started a virtual machine for you, and a Kubernetes cluster is now running in that VM.


```
minikube start --vm-driver=docker -p dc1`

useradd dc1 --create-home
useradd dc2 --create-home

usermod -a -G docker dc1

usermod -a -G docker dc2

minikube start --vm-driver=docker -p dc2 -v 8
```


`useradd consul --create-home -G docker -s /bin/bash`{{execute}}

`runuser -l consul -c "minikube start --vm-driver=docker -p dc1 -v 8 --memory 1024"`{{execute}}

`runuser -l consul -c "minikube start --vm-driver=docker -p dc2 -v 8 --memory 1024"`{{execute}}

`su - consul`{{execute}}

`helm repo add hashicorp https://helm.releases.hashicorp.com`{{execute}}

`kubectl config use-context dc1`{{execute}}


`git clone https://github.com/hashicorp/consul-helm.git`{{execute}}
`cd consul-helm`{{execute}}
`git checkout wan-federation-base`{{execute}}
`cd ..`{{execute}}


`helm install consul ./consul-helm -f ./dc1-config.yaml --timeout 10m`{{execute}}

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

`kubectl config use-context dc2`{{execute}}