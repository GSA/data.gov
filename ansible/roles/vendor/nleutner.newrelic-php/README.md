# Ansible Role: New Relic PHP Agent

This ansible role installs and configures the New Relic PHP Agent on RHEL/CentOS, Debian & Ubuntu based systems.


## Requirements

This role requires Ansible 1.4 higher, platforms are listed in the metadata file.

## Role Variables


Example variables are listed below (see `defaults/main.yml`):
All variables used by /etc/php.d/newrelic.ini may be configured using ansible variables.

    # Setting: newrelic.license
    newrelic_license_key: 0123456789012345678901234567890123456789

    # Setting: newrelic.appname
    newrelic_agent_appname: "Symfony Application"

## Examples

### Paramaterized Role

    ---
    - hosts: all
      roles:
        - { role: newrelic-php, newrelic_license_key: 0123456789012345678901234567890123456789 }

### Vars

    ---
    - hosts: all
      vars:
        newrelic_license_key: 0123456789012345678901234567890123456789
      roles:
        - newrelic-php

### Group vars

#### group_vars/production

    ---
    newrelic_license_key: 0123456789012345678901234567890123456789

#### paybook.yml

    ---
    - hosts: all
      roles:
        - newrelic-php
