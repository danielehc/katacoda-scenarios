Once gossip encryption is configured the key gets stored in Consul data folder and is not possible to change it by changing the configuration file.

Consul provides a command, `consul keyring` that helps manage keys in the datacenter.

`consul keyring -list`{{execute T1}}

Example output

```
```

To install and use a new key the steps are the following:

1. Get the new key.
1. Use `consul keyring -install "<new_gossip_key>"` to insert the key in the keyring. This will propagate the key to all nodes in the datacenter automatically.
1. Use `consul keyring -use "<new_gossip_key>"` to promote the key as primary.

After you install the new key the keyring will contain both the previous key and the new one.

Once you installed the new key and promoted it as primary, you should then remove all the former keys, to avoid nodes being able to join the gossip pool with an old key.

For this you can use the `command` option of `consul-template` that permits you to define a command to be executed every time a new version of the key is found.

### Write a rotation script

To automate the rotation tou can write a bash script that will manage the steps for you.

This lab contains an example script, `rotate_key.sh`{{open}}, that you can use for this.

First stop Consul template:

`killall consul-template`{{execute T1}}

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Warning:</strong><br>
  
  You should not use `killall` on a production server unless you are sure of the processes running on the node.

</p></div>

Then copy the script in a location contained in your `$PATH`:

`cp rotate_key.sh /usr/local/bin`{{execute T1}}

Now you can restart it using the new configuration file `consul_template_autorotate.hcl`{{open}} that contains the configuration

`consul-template -config "consul_template_autorotate.hcl"`{{execute T2}}



<!-- Primary keys 
curl -s localhost:8500/v1/operator/keyring | jq -r '.[].PrimaryKeys| to_entries[].key'

curl -s localhost:8500/v1/operator/keyring | jq -r '.[].Keys| to_entries[].key'

Sort and uniq and use the key retrieved as a value to grep -v
-->