Kind           = "service-resolver"
Name           = "ingress-service"
LoadBalancer = {
  Policy = "maglev"
  HashPolicies = [
    {
      Field = "header"
      FieldValue = "x-user-id"
    }
    ]
}