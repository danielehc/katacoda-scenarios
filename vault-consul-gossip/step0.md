
## Start Vault

`mkdir -p ~/log`{{execute T1}}

`nohup sh -c "vault server -dev -dev-root-token-id="root" -dev-listen-address=0.0.0.0:8200 >~/log/vault.log 2>&1" > ~/log/nohup.log &`{{execute T1}}

`export VAULT_ADDR='http://127.0.0.1:8200'`{{execute T1}}

`export VAULT_TOKEN="root"`{{execute T1}}

<div style="background-color:#fcf6ea; color:#866d42; border:1px solid #f8ebcf; padding:1em; border-radius:3px;">
  <p><strong>Warning: </strong>
  This lab launches Vault in dev mode. This is not suggested for production.
</p></div>



`openssl rand -base64 16`{{execute T1}}

> Alternatively, you can use any method that can create 16 random bytes encoded in base64.
>
> * **Method 2: openssl**
> 
> `openssl rand -base64 16`{{execute T1}}
>
> * **Method 3: dd** 
>
> `dd if=/dev/urandom bs=16 count=1 status=none | base64`{{execute T1}}


<div style="background-color:#eff5ff; color:#416f8c; border:1px solid #d0e0ff; padding:1em; border-radius:3px; margin:24px 0;">
  <p><strong>Info: </strong>

Alternatively, you can use any method that can create 16 random bytes encoded in base64.
<br/>

<ul>
<li>
* **Method 2: openssl** <br/>
`openssl rand -base64 16`{{execute T1}} <br/>
</li>
<li>
* **Method 3: dd** <br/>
`dd if=/dev/urandom bs=16 count=1 status=none | base64`{{execute T1}} <br/>
</li>
<ul>
</p></div>