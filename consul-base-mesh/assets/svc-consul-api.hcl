service {
  name = "consul-api"
  port = 443
  connect {
    sidecar_service {}
  }
  check {
    id = "consul-api-check"
    http = "https://localhost:443"
    tls_skip_verify = true
    method = "GET"
    interval = "1s"
    timeout = "1s"
  }
}