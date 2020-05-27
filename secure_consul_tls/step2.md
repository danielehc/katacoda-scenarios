#### Add HashiCorp repository in Helm

Once Kubernetes is running you can the official Consul Helm chart repo directly from the commandline.

`helm repo add hashicorp https://helm.releases.hashicorp.com`{{execute}}

#### Configure Consul service mesh

The scenario comes with a prepared configuration.

`consul-values.yml`{{open}}

#### Deploy Consul with Helm

`helm install -f ~/consul-values.yml hashicorp hashicorp/consul`{{execute}}

#### Check services running in Kubernetes

Control Consul is properly running.

`kubectl get services`{{execute}}

