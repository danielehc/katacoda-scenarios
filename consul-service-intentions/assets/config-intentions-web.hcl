Kind = "service-intentions"
Name = "web"
Sources = [
  {
    Name = "ingress-service"
    Permissions = [
      {
        Action = "allow"
        HTTP {
          PathExact = "/ui"
          Methods   = ["GET"]
        }
      }
    ]
  },
  # NOTE: a default catch-all based on the default ACL policy will apply to
  # unmatched connections and requests. Typically this will be DENY.
]