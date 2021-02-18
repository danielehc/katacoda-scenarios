### Use the `status` API 

CTS provides the `/status` REST endpoints to share status-related information 
for tasks. This information is available for understanding the status of 
individual tasks and across tasks.

The health status value is determined by aggregating the success or failure of 
the event of a task detecting changes in Consul services and then updating 
network infrastructure. 

Currently, only the 5 most recent events are stored in Consul-Terraform-Sync. 

`curl --silent localhost:8558/v1/status | jq`{{execute T1}}

```json
{
  "task_summary": {
    "successful": 1,
    "errored": 0,
    "critical": 0
  }
}
```

### Terraform state in Consul

When using Consul as a backend for CTS the Terraform state will be persisted in
the Consul KV store as a different state file for each task.

The default path for the state object is `consul-terraform-sync/terraform-env:task-name`
with `task-name` being the task identifer appended to the end of the path.

You can check 
