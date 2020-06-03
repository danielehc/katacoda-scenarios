
You can now use the bootstrap token to create other ACL policies for the rest of your datacenter.

`docker cp ./agent.hcl volumes:/client/agent.hcl`{{execute T3}}




`kubect apply -f ~/api.yml`{{execute}}


`kubect apply -f ~/web.yml`{{execute}}
