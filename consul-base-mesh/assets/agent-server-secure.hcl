## Service Mesh Configuration
connect {
  enabled = true
  ca_provider = "consul"
}

addresses {
  grpc = "127.0.0.1"
  http = "0.0.0.0"
  // http = "127.0.0.1"
  // https = "127.0.0.1"
  dns = "127.0.0.1"
}


ports {
  grpc  = 8502
  http  = 8500
  https = -1
  dns   = 53
}

recursors = ["8.8.8.8"]

## Centralized configuration
enable_central_service_config = true

## Data Persistence
data_dir = "/tmp/consul"

## TLS Encryption (requires cert files to be present on the server nodes)
verify_incoming        = false
verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true

ca_file   = "/etc/consul.d/consul-agent-ca.pem"
cert_file = "/etc/consul.d/server-consul-0.pem"
key_file  = "/etc/consul.d/server-consul-0-key.pem"

auto_encrypt {
  allow_tls = true
}

## ACL (for now embedded with standard master token)
acl {
  enabled        = true
  default_policy = "deny"
  enable_token_persistence = true
  // tokens {
  //   master = "root"
  //   agent  = "root"
  //   // default  = "root"
  // }
}

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname= false
}
