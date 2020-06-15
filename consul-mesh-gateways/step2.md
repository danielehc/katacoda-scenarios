The cluster can be interacted with using the kubectl CLI. This is the main approach used for managing Kubernetes and the applications running on top of the cluster.

Details of the cluster and its health status can be discovered via 
`kubectl cluster-info`{{execute}}


To view the nodes in the cluster use
`kubectl get nodes`{{execute}}

If the node is marked as NotReady then it is still starting the components.

This command shows all nodes that can be used to host our applications. Now we have only one node, and we can see that it’s status is ready (it is ready to accept applications for deployment).

