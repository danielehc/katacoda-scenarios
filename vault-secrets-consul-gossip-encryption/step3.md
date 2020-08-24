### Configure and Start Consul

This labs comes with a prepared Consul server configuration.

Open `server.hcl`{{open}} in the editor to review the values required for a minimal server configuration with gossip encryption enabled.

Notice that the configuration includes a line that requires manual editing.

```
encrypt = "<insert gossip encryption here>"
```

Insert the previously generated gossip key in the configuration file and save.

## Start Consul

`consul agent -config-file server.hcl`{{execute T1}}
