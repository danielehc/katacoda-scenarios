#### Deploy frontend application in your service mesh

The scenario comes with a prepared configuration.

`web.yml`{{open}}

#### Deploy app with kubectl

YOu can deploy the `web` application using `kubectl`.

`kubectl apply -f ~/web.yml`{{execute}}


#### Check application is running in Kubernetes

`kubectl get pods`{{execute}}


### Verify application status in Consul UI

Open [Consul UI](https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com/ui/minidc/services) and ensure two services `api` and `api-sidecar-proxy` are registered and healthy in Consul.
