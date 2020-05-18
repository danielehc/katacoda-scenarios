#### Add HashiCorp repository in Helm

`helm repo add hashicorp https://helm.releases.hashicorp.com`{{execute}}


#### Deploy Consul using Helm

`helm install -f ~/config/consul-values.yml hashicorp hashicorp/consul`{{execute}}

