# TLS

Installs a TLS/SSL certificate and key for the host.


## Role Variables

**common_tls_host_certificate** string

File content of the TLS/SSL certificate in PEM format.

**common_tls_host_key** string

File content of the TLS/SSL certificate key in PEM format.


## Example playbook

```
- hosts: servers
  roles:
     - role: tls
       common_tls_host_certificate: |-
         ----BEGIN RSA CERTIFICATE----
	 certificate data
         ----END RSA CERTIFICATE----

       common_tls_host_key: |-
         ----BEGIN PRIVATE RSA----
	 private certificate key data
         ----END RSA CERTIFIATE----
```
