## ACL (for now embedded with standard master token)
acl {
  tokens {
    ## [Deprecated] You should properly bootstap ACL in the DC
    ## Will be removed in a future iteration of the sandbox environment
    master = "root"
    ## Should have only minimal permissions to stay in the DC ?
    agent  = "root"
    ## This can be the DNS token for the agents serving DNS requests
    ## But can also be omitted for other ones. ?
    default  = "root"
  }
}
