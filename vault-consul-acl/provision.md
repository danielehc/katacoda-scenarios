There are a few components that need to be added to the environment; we are
adding them now. Wait for the complete message and then move to the
next step.

**Example Output**

```screenshot
- Install prerequisites
- Install Consul locally
- Installing Consul x.y.z
- Pulling Docker image for Consul x.y.z
- Creating Docker volumes
```

and concluding with

```
- Complete! Move on to the next step.
```

Once this message appears, you are ready to continue.


### Configuration files

While you wait for the provision to complete you can review the configuration files you are going to use for the lab:

| File                           | Description |
|:-------------------------------|-------------|
| `server.hcl`{{open}}           | Configuration for Server node |
| `server_policy.hcl`{{open}}    | Server ACL policy for token generation |