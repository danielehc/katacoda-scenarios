

This hands-on lab comes with a prepared configuration for the `web` service.

`web.yml`{{open}}

In addition to the `"consul.hashicorp.com/connect-inject": "true"` annotation, the
`web` service defines the `"consul.hashicorp.com/connect-service-upstreams"` annotation. This annotation explicitly declares the upstream for the web service, which is the `api` service you deployed previously.

#### Deploy app with kubectl

You can deploy the `web` application using `kubectl`.

`export KUBECONFIG=${HOME}/.shipyard/config/dc2/kubeconfig.yaml`{{execute}}

`kubectl apply -f ~/web.yml`{{execute}}

#### Check the service is running in Kubernetes

Finally, you can verify the `web` service is deployed successfully.

`kubectl get pods`{{execute}}

Wait until the pod is marked as `Running` to continue. This might take up to a minute to complete

### Verify application status in Consul UI

Open [Consul UI](https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/ui/dc2/services) and ensure the service `web` is registered and healthy in Consul.