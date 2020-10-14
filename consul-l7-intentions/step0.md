

# Set backend to http and apply resolver

```
Kind           = "service-defaults"
Name           = "backend"
Protocol       = "http"
```

`docker exec server consul config write /etc/consul.d/default.hcl`{{execute}}

Example output:

```
Config entry written: service-defaults/backend
```

# Apply resolver for sticky session

```
Kind           = "service-resolver"
Name           = "backend"
LoadBalancer = {
  EnvoyConfig = {
    Policy = "maglev"
    HashPolicies = [
      {
        Field = "header"
        FieldValue = "x-user-id"
      }
    ]
  }
}
```

`docker exec server consul config write /etc/consul.d/hash-resolver.hcl`{{execute}}

Example output:

```
Config entry written: service-resolver/backend
```

# Run requests against client proxy with header in service resolver

It should reach the same backend service instance every time

`docker exec client curl -s localhost:9192 -H "x-user-id: 12345"`{{execute}}

Example output:

```
{
  "name": "main",
  "uri": "/",
  "type": "HTTP",
  "ip_addresses": [
    "172.18.0.4"
  ],
  "start_time": "2020-09-08T16:15:47.950151",
  "end_time": "2020-09-08T16:15:47.950581",
  "duration": "430.088µs",
  "body": "Hello World",
  "code": 200
}
```

# Run request with a different user-id and it should stick to a different instance

`docker exec client curl -s localhost:9192 -H "x-user-id: 1010101"`{{execute}}

Example output:

```
{
  "name": "clone",
  "uri": "/",
  "type": "HTTP",
  "ip_addresses": [
    "172.18.0.5"
  ],
  "start_time": "2020-09-08T16:15:49.155875",
  "end_time": "2020-09-08T16:15:49.155979",
  "duration": "103.381µs",
  "body": "Hello World",
  "code": 200
}
```

# Apply new resolver with least_request algorithm

```
Kind           = "service-resolver"
Name           = "backend"
LoadBalancer = {
  EnvoyConfig = {
    Policy = "least_request"
  }
}
```

`docker exec server consul config write /etc/consul.d/least-req-resolver.hcl`{{execute}}

Example output:

```
Config entry written: service-resolver/backend
```

# Requests should bounce around between backend instances

`docker exec client curl -s localhost:9192 -H "x-user-id: 12345"`{{execute}}

Example output:

```
{
  "name": "main",
  "uri": "/",
  "type": "HTTP",
  "ip_addresses": [
    "172.18.0.4"
  ],
  "start_time": "2020-09-08T16:15:54.151406",
  "end_time": "2020-09-08T16:15:54.151885",
  "duration": "478.867µs",
  "body": "Hello World",
  "code": 200
}
```