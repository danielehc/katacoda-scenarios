

# Set backend to http and apply resolver

`docker exec server consul config write /server/default.hcl`{{execute}}

# Apply resolver for sticky session
`docker exec server consul config write /server/hash-resolver.hcl`{{execute}}

# Run requests against client proxy with header in service resolver

It should reach the same backend service instance every time

`docker exec client curl -s localhost:9192 -H "x-user-id: 12345"`{{execute}}

# Run request with a different user-id and it should stick to a different instance

`docker exec client curl -s localhost:9192 -H "x-user-id: 1010101"`{{execute}}

# Apply new resolver with least_request algorithm

`docker exec server consul config write /server/least-req-resolver.hcl`{{execute}}

# Requests should bounce around between backend instances

`docker exec client curl -s localhost:9192 -H "x-user-id: 12345"`{{execute}}