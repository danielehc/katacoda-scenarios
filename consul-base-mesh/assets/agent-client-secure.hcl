## Service Mesh Configuration
// connect {
//   enabled = true
// }

ports {
  grpc = 8502
}

## Centralized configuration
enable_central_service_config = true

## Data Persistence
data_dir = "/tmp/consul"

## TLS Encryption (requires cert files to be present on the server nodes)
verify_incoming        = false
verify_outgoing        = true
verify_server_hostname = true

ca_file = "consul-agent-ca.pem"

auto_encrypt {
  tls = true
}

## ACL (for now embedded with standard master token)
acl {
  enabled        = true
  default_policy = "deny"
  tokens {
    master = "root"
    agent  = "root"
  }
}
