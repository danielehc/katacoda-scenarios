#### Add HashiCorp repository in Helm

`helm repo add hashicorp https://helm.releases.hashicorp.com`{{execute}}


#### Deploy Consul using Helm

`helm install -f ~/config/consul-values.yml hashicorp hashicorp/consul`{{execute}}

#### Check Services being created in Kubernetes

`kubectl get services`{{execute}}


kubectl port-forward service/hashicorp-consul-ui 80:80 --address `hostname -I | awk '{print $1}'`

