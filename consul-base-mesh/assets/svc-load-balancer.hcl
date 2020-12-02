service {
  name = "load-balancer"
  port = 443
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