# datagov-deploy-dashboard

Ansible role to deploy the [Project Open Data
Dashboard](https://labs.data.gov/dashboard) on the Data.gov platform.


## Usage

This role assumes you've already installed git, nginx, php, php-fpm, and
composer. Add this role and its dependencies to your requirements.yml file.

```yaml
---
- src: https://github.com/GSA/datagov-deploy-dashboard
  version: v1.0.0
  name: gsa.datagov-deploy-dashboard
- src: geerlingguy.composer
- src: geerlingguy.git
- src: geerlingguy.nginx
- src: geerlingguy.php
- src: geerlingguy.php-versions
```

Install with ansible-galaxy.

    $ ansible-galaxy install -r requirements.yml

Example playbook.

```yaml
---
- name: install dashboard
  roles:
    - role: geerlingguy.git
    - role: geerlingguy.nginx
    - role: geerlingguy.php-versions
    - role: geerlingguy.php
    - role: geerlingguy.composer
    - role: gsa.datagov-deploy-dashboard
```


### Variables


#### `dashboard_php_major_minor_version` default: "7.3"

The major-minor version of PHP to install against.
