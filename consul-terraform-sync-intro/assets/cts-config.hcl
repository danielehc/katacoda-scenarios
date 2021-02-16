log_level = "TRACE"
buffer_period {
 enabled = true
 min     = "5s"
 max     = "15s"
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
 description = "this has 2 instances"
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
 name        = "example"
 description = "example task with one service"
 source      = "findkim/print/cts"
 version     = "0.1.0"
 services    = ["web", "api"]
}