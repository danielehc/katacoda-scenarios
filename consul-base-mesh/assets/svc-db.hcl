service {
  name = "db"
  id = "db-1"
  port = 9004
  connect {
    sidecar_service {}
  }
  check {
    id = "db-check"
    http = "http://localhost:9004/health"
    method = "GET"
    interval = "1s"
    timeout = "1s"
  }
}