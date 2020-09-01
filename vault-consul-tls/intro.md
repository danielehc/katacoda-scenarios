# Secure Consul Agent Communication with ACL

In this hands-on lab, you will deploy a secure Consul datacenter using Vault to generate and manage certificates.

The lab will guide you through the steps necessary to deploy Consul with TLS encryption enabled to secure access to the UI, API, CLI, services, and agents.

Specifically, you will:

- Start a Vault dev instance
- Create a policy in Vault to allow certificate generation
- Enable the PKI engine in Vault
- Initialize the CA and generate an intermediate certificate
- Generate certificates for your Consul servers
- Use consul-template to retrieve certificates at runtime
- Perform a certificate rotation

If you are already familiar with the basics of Consul, [Secure Consul with ACLs](https://learn.hashicorp.com/consul/security-networking/production-acls) provides a reference guide for the steps required to enable and use ACLs on your Consul datacenter.
