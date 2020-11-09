## Service Mesh Configuration
// connect {
//   enabled = true
// }

ports {
  grpc = 8502
  http = -1
  https = 8501
}

## Centralized configuration
enable_central_service_config = true

## Data Persistence
data_dir = "/tmp/consul"

## TLS Encryption (requires cert files to be present on the client nodes)
verify_incoming        = false
verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true


ca_file = "/etc/consul.d/consul-agent-ca.pem"

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
    default  = "root"
  }
}
