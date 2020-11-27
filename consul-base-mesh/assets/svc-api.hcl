service {
  name = "api"
  id = "api-1"
  port = 9003
  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "db"
            local_bind_port = 5000
          }
        ]
      }
    }
  }
  check {
    id = "api-check"
    http = "http://localhost:9003/health"
    method = "GET"
    interval = "1s"
    timeout = "1s"
  }
}