# Secure Consul Agent Communication with ACL

In this hands-on lab, you will deploy a secure Consul
datacenter using Vault to generate and manage ACL tokens.

The lab will guide you through the steps necessary to
deploy Consul with TLS encryption enabled to secure access
to the UI, API, CLI, services, and agents.

Specifically, you will:
- Start a Vault dev instance
- Start a Consul datacenter with ACL enabled
- Bootstrap ACLs in Consul
- Create a Consul policy for servers
- Enable Consul secrets engine in Vault
- Create a management token for Vault
- Create a Vault role to map Consul policy
- Create a Vault token associated with the role
- Verify the token was present in Consul and applied it to the agent

If you are already familiar with the basics of Consul,
[Secure Consul with ACLs](https://learn.hashicorp.com/consul/security-networking/production-acls)
provides a reference guide for the steps required to enable and use ACLs on your Consul datacenter.
