# gsa.datagov-deploy-jumpbox

This role configures the jumpbox host for access by operators.

- User accounts are locked
- Users have password-less sudo access
- Users are allowed SSH access by the specified public key

## Requirements

- [Ansible](https://www.ansible.com/) 2.6+

## Usage

Add gsa.datagov-deploy-jumpbox to your requirements.yml and install with
ansible-galaxy.

Example Playbook
-------------------------

```
---
- name: Jumpbox
  hosts: all
  roles:
    - role: jumpbox
```


### Variables

**jumpbox_operators** list<object>

The user accounts to create on the jumpbox. User objects should include
a `username`, `email`, and `public_key` (contents of the users id_rsa.pub). The
authorized_keys is set exclusively to this key, so any modifications to
authorized_keys will be overridden the next time this role is run.
