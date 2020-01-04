# datagov-deploy-wordpress

Ansible role to deploy WordPress on the Data.gov platform.


## Usage

Example playbook.

```yaml
---
- name: Deploy wordpress
  hosts: all
  roles:
    - role: geerlingguy.git
    - role: geerlingguy.nginx
    - role: geerlingguy.php-versions
    - role: geerlingguy.php
    - role: geerlingguy.php-mysql
    - role: geerlingguy.php-memcached
    - role: software/common/php-fixes
    - role: geerlingguy.composer
    - role: gsa.datagov-deploy-wordpress
      datagov_team_email: team@example.com
```


### Variables

#### `datagov_team_email` **required**

Email address for the Data.gov team. Reports are sent to this address.
