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
 address = "172.19.0.3:443"
//  tls {
//   verify = fasle
//  }
 # tls {
 #   ca_cert = "some_cert"
 #   # key     = "my_key"
 # }
}
service {
 name = "api"
 tag = "dne"
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
 source      = "findkim/print/c"
 version     = "0.0.0-alpha"
 services    = ["web", "api"]
