#### Deploy services into Consul service mesh

You will deploy two services, web and api, into Consul's service mesh running on a Kubernetes cluster. The two services will use Consul to discover each other and communicate over mTLS with sidecar proxies. This is the first step in deploying an application into a zero-trust network.

The two services represent a simple two-tier application made of a backend api service and a frontend that communicates with the api service over HTTP and exposes the results in a web ui.

#### Deploy the backend service 

This hands-on lab comes with a prepared configuration.

`api.yml`{{open}}

The `"consul.hashicorp.com/connect-inject": "true"` annotation in the configuration ensures a sidecar proxy is automatically added to the `api` pod. This proxy will handle inbound and outbound service connections, automatically wrapping and verifying TLS connections.

#### Deploy the service with kubectl

You can deploy the `api` service using `kubectl`.

`kubectl apply -f ~/api.yml`{{execute}}

#### Check the service is running in Kubernetes

Finally, you can verify the `api` service is deployed successfully. 

`kubectl get pods`{{execute}}

Wait until the pod is marked as `Running` to continue. This might take up to a minute to complete.

### Verify application status in Consul UI

Open [Consul UI](https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/ui/minidc/services) and ensure two services `api` and `api-sidecar-proxy` are registered and healthy in Consul.
