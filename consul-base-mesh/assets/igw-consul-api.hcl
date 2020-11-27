Kind = "ingress-gateway"
Name = "ingress-consul-api"

Listeners = [
 {
   Port = 8443
   Protocol = "http"
   Services = [
     {
       Name = "consul-api"
       Hosts = ["*"]
     }
   ]
 }
]