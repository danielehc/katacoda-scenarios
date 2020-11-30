service {
  name = "prometheus"
  port = 9090
  connect {
    sidecar_service {}
  }
  check {
    id = "prometheus-check"
    http = "http://localhost:9090/-/healthy"
    method = "GET"
    interval = "1s"
    timeout = "1s"
  }
}