Kind = "ingress-gateway"
Name = "ingress-load-balancer"

Listeners = [
 {
   Port = 8443
   Protocol = "http"
   Services = [
     {
       Name = "load-balancer"
       Hosts = ["*"]
     }
   ]
 }
]