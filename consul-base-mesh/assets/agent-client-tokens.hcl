## ACL (for now embedded with standard master token)
acl {
  tokens {
    ## Should have only minimal permissions to stay in the DC ?
    agent  = "root"
    ## This can be the DNS token for the agents serving DNS requests
    ## But can also be omitted for other ones. ?
    default  = "root"
  }
}
