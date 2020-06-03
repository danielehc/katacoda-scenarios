
To verify ACLs are in place you can query consul to retrieve the list of nodes and services.


### Change the token

The previous request was successful because you still had the bootstrap token exported in `CONSUL_HTTP_TOKEN`.

`unset CONSUL_HTTP_TOKEN`{{execute T1}}

After unsetting it, try again the same commands:

`consul members`{{execute T1}}
