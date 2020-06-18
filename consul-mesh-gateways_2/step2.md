To configure the secondary datacenter (`dc2`) you will need to configure it to be able to reach the primary (`dc1`). You can use the *federation secret* to automate this step.

The federation secret is a Kubernetes secret containing information needed for secondary datacenters/clusters to federate with the primary. This secret is created automatically by setting:

```
global:
  federation:
    createFederationSecret: true
```

in your Helm chart configuration.

After the installation into your primary cluster you will need to export this secret:

`kubectl get secret consul-federation -o yaml > consul-federation-secret.yaml`{{execute}}

The secret contains several configuration info. Particularly important is the portion of server configuration to define federation using mesh gateways:

`cat consul-federation-secret.yaml | grep serverConfigJSON: | awk '{print $2}' | base64 -d`{{execute}}

<div style="background-color:#fbe5e5; color:#864242; border:1px solid #f8cfcf; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Security note:</strong><br>
  
 The federation secret makes it possible to gain full admin privileges in Consul. This secret must be kept securely, i.e. it should be deleted from your filesystem after importing it to your secondary datacenter and you should use RBAC permissions to ensure only administrators can read it from Kubernetes.

</p></div>
