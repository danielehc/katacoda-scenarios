
To start using ACLs you need to bootstrap them.

First login into Consul server node:

`docker exec -it server /bin/sh`{{execute T2}}

And make sure you configure the environment to reach Consul:

`export CONSUL_HTTP_ADDR=localhost:8500`{{execute T2}}


### Bootstrap ACLs

To start using ACLs you need to bootstrap them.

Run `consul acl bootstrap | tee consul.bootstrap`{{execute}} to bootstrap the ACL system, generate your first token, and capture the output into the `consul.bootstrap` file.

If you receive an error saying "The ACL system is currently in legacy mode.", this indicates that the Consul service is still starting. Wait a few seconds and try the command again.

Example Output

```
$ consul acl bootstrap | tee consul.bootstrap
AccessorID:       e57b446b-2da0-bce2-f01c-6c0134d8e19b
SecretID:         bba19e7c-9f47-2b08-f0ea-e1bca43ba9c5
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2020-02-20 17:01:13.105174927 +0000 UTC
Policies:
   00000000-0000-0000-0000-000000000001 - global-management
```

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>
  In this hands-on lab we are redirecting the output for the `consul acl bootstrap` command on a file to simplify operations in the next steps. In a real-life scenario you want to make sure the bootstrap token is stored in a safe place as having it compromised will disprove ACL safety.
</p></div>


cat consul.bootstrap  | grep SecretID  | awk '{print $2}'

consul members -token $(cat consul.bootstrap  | grep SecretID  | awk '{print $2}')