## Global Config
log_level = "INFO"
port = 8558

syslog {}

buffer_period {
  enabled = true
  min = "5s"
  max = "20s"
}

driver "terraform" {
 # version = "0.14.0"
 # log         = true
 persist_log = false
}
consul {
 address = "localhost:8500"
//  tls {
//   verify = false
//  }
 # tls {
 #   ca_cert = "some_cert"
 #   # key     = "my_key"
 # }
}
service {
 name = "api"
 tag = "cts"
 # namespace = "my-team"
 # datacenter  = "dc1"
 description = "Match only services with a specific tag"
}
# task {
#   name        = "print"
#   description = "this task prints output and creates files with content"
#   source      = "../../test/output"
#   # source   = "findkim/print/c"
#   # version  = "0.0.0-alpha"
#   services = ["api", "web"]
#   variable_files = ["/Users/kngo/dev/hashicorp/consul-terraform-sync/test/output/test.tfvars", "/Users/kngo/dev/hashicorp/consul-terraform-sync/test/output/override.tfvars"]
#   buffer_period {
#     enabled = true
#     min     = "10s"
#     max     = "25s"
#   }
# }
task {
 name        = "learn-cts-example"
 description = "Example task with one service"
 source      = "findkim/print/c"
 version     = "0.0.0-alpha"
 services    = ["web", "api"]
}