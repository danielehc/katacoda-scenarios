# Run services (https://github.com/nicholasjackson/fake-service)
env LISTEN_ADDR=:9091 NAME=main fake-service
env LISTEN_ADDR=:9092 NAME=clone fake-service

# Install services
consul services register svc-main.hcl
consul services register svc-clone.hcl
consul services register svc-client.hcl

# Set backend to http and apply resolver
consul config write default.hcl

# Apply resolver for sticky session
consul config write hash-resolver.hcl

# Spin up sidecar proxies for each
consul connect envoy -proxy-id backend-main-sidecar-proxy
consul connect envoy -admin-bind=localhost:19001 -proxy-id backend-clone-sidecar-proxy
consul connect envoy -admin-bind=localhost:19002 -proxy-id client-sidecar-proxy

# Run requests against client proxy with header in service resolver
# It should reach the same backend service instance every time
curl localhost:9192 -H "x-user-id: 12345"

# Run request with a different user-id and it should stick to a different instance
curl localhost:9192 -H "x-user-id: 1010101"

# Apply new resolver with least_request algorithm
consul config write least-req-resolver.hcl

# Requests should bounce around between backend instances
curl localhost:9192 -H "x-user-id: 12345"