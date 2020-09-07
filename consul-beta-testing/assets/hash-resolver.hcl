Kind           = "service-resolver"
Name           = "backend"
LoadBalancer = {
  EnvoyConfig = {
    Policy = "maglev"
    HashPolicies = [
      {
        Field = "header"
        FieldValue = "x-user-id"
      }
    ]
  }
}