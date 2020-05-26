#### Deploy backend application in your service mesh

The scenario comes with a prepared configuration.

`api.yml`{{open}}

#### Deploy app with kubectl

YOu can deploy the `api` application using `kubectl`.

`kubectl apply -f ~/api.yml`{{execute}}


#### Check application is running in Kubernetes

`kubectl get pods`{{execute}}

Wait until the pod is marked as `Running` to continue. This might take up to a minute to complete.

### Verify application status in Consul UI

Open [Consul UI](https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/ui/minidc/services) and ensure two services `api` and `api-sidecar-proxy` are registered and healthy in Consul.

