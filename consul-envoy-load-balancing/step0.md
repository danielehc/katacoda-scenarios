

# Set backend to http and apply resolver

`consul config write default.hcl`{{execute}}

# Apply resolver for sticky session
`consul config write hash-resolver.hcl`{{execute}}

# Run requests against client proxy with header in service resolver

It should reach the same backend service instance every time

`curl localhost:9192 -H "x-user-id: 12345"`{{execute}}

# Run request with a different user-id and it should stick to a different instance

`curl localhost:9192 -H "x-user-id: 1010101"`{{execute}}

# Apply new resolver with least_request algorithm

`consul config write least-req-resolver.hcl`{{execute}}

# Requests should bounce around between backend instances

`curl localhost:9192 -H "x-user-id: 12345"`{{execute}}