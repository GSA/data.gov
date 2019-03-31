[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy-php.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy-php)

# datagov-deploy-php

Ansible role for deploying PHP for web applications on the Data.gov platform.


## Usage

```yaml
---
- name: Configure PHP for web app
  roles:
    - role: geerlingguy.nginx
    - role: geerlingguy.php
      vars:
        php_default_version_debian: "7.0"
        php_enable_php_fpm: true
        php_webserver_daemon: nginx
    - software/common/php-fixes
```

### Dependencies

- [geerlingguy.nginx](https://github.com/geerlingguy/ansible-role-nginx).
- [geerlingguy.php](https://github.com/geerlingguy/ansible-role-php).

This role assumes the version of PHP you're requesting is available in the OS
package repository already. If not, you probably want to install a ppa first.
_TODO: make this part of the role. Currently it is part of php-common._

```
- name: Prepare
  hosts: all
  pre_tasks:
    - name: Add repository for PHP
      apt_repository:
        repo: "ppa:ondrej/php"
      register: ppa

    - name: Update Apt
      apt: update_cache=yes
      when: ppa is changed
```

### Variables

#### `php_fpm_request_terminate_timeout` string

Specifies the PHP-FPM `request_terminate_timeout` configuration option. e.g.
`30s`.
