## Service Mesh Configuration
connect {
  enabled = true
  ca_provider = "consul"
}

ports {
  grpc = 8502
  http = 8500
  https = -1
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
// cert_file = "/etc/consul.d/dc1-client-consul-0.pem"
// key_file  = "/etc/consul.d/dc1-client-consul-0-key.pem"

auto_encrypt {
  tls = true
}

## ACL (for now embedded with standard master token)
acl {
  enabled        = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    master = "root"
    agent  = "root"
    //default  = "root"
  }
}
