Kind           = "service-resolver"
Name           = "backend"
LoadBalancer = {
  EnvoyConfig = {
    Policy = "least_request"
  }
}