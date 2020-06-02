#### Add HashiCorp repository in Helm

Once Kubernetes is running, you can add the official HashiCorp Consul Helm chart repo directly from the command line.

`helm repo add hashicorp https://helm.releases.hashicorp.com`{{execute}}

The chart helps you automate the installation and configuration of Consul’s core features for Kubernetes.

#### Configure Consul service mesh

This hands-on lab comes with a prepared configuration.

`consul-values.yml`{{open}}

Note the following settings:

* The server key contains parameters related to the server pods. The chart is configured to create one Consul server per Kubernetes node.
* The Consul “connect” service mesh is enabled by setting the connectInject key to true. When the “connect” injector is installed, then a sidecar proxy is automatically added to all pods.
* The Consul web UI update the ui section and set enabled to true.

#### Deploy Consul with Helm

You will use `helm install` to deploy Consul using the configuration defined in `consul-values.yml`. This should only take a few minutes. 

`helm install -f ~/consul-values.yml hashicorp hashicorp/consul`{{execute}}

#### Verify the Consul deployment

Execute `kubectl get services` from the command line to verify the services, including Consul, are being exposed from the Kubernetes cluster.

`kubectl get services`{{execute}}

You should have the following four Consul services:

* hashicorp-consul-server
* hashicorp-consul-connect-injector-svc                                                                    
* hashicorp-consul-dns
* hashicorp-consul-ui
