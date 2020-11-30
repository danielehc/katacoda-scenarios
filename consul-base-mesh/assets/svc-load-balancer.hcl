service {
  name = "load-balancer"
  port = 443
  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "prometheus"
            local_bind_port = 9090
          },
          {
            destination_name = "web"
            local_bind_port = 5000
          }
        ]
      }
    }
  }
  check {
    id = "load-balancer-api-check"
    http = "https://localhost:443"
    # Only for Dev, when using a public CA signed 
    # certificate this line should be removed
    tls_skip_verify = true
    method = "GET"
    interval = "1s"
    timeout = "1s"
  }
}