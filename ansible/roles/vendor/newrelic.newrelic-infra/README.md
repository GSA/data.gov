# newrelic-infra Ansible role

[![Build Status](https://travis-ci.org/newrelic/infrastructure-agent-ansible.svg?branch=master)](https://travis-ci.org/newrelic/infrastructure-agent-ansible)

## Description

This role installs and configures the New Relic Infrastructure agent.

Note that this is a simple role and is intended for you to use as a starting
place for your own customized workflow.

## Setup

### What newrelic-infra affects

* Adds the New Relic Infrastructure package repository source
* Installs and configures the New Relic Infrastructure agent

### Beginning with newrelic-infra

Include the role in your playbook. Customize the required variables.

## Usage

All typical interactions with newrelic-infra will be done through role configuration.

### Installing the Infrastructure agent

```yaml
---
- hosts: ap_ne_1
  roles:
    - name: newrelic.newrelic-infra
      vars:
        nrinfragent_config:
          license_key: YOUR_LICENSE_KEY
          log_file: /var/log/nr-infra.log
          log_to_stdout: false
```

## Reference

### Role Configuration

#### Variables

##### `nrinfragent_state` (OPTIONAL)

Describes what you want to do with the agent:

* `'latest'` - [default] install the latest version of the agent. Also `present`.
* `'absent'` - Uninstall the agent.

##### `nrinfragent_os_name` (OPTIONAL)

Specifies the target OS that the Infrastructure agent will be installed on.
Defaults to `ansible_os_family`. See list in the `meta/main.yml` file for latest list that is supported.

##### `nrinfragent_os_version` (OPTIONAL)

Specifies the OS version of the installer package needed for this machine.
Defaults to `ansible_lsb.major_release`. Mostly used for `RedHat` family OSs. See list in the `meta/main.yml` file for latest list.

##### `nrinfragent_os_codename` (OPTIONAL)

Specifies the OS codename of the installer package needed for this machine.
Defaults to `ansible_lsb.codename`. Mostly used for `Debian` family OSs. See list in the `meta/main.yml` file for latest list.

##### `nrinfragent_config` (REQUIRED)

Used to populate agent configuration. At a minimum you must provide `license_key`.
See the NewRelic documentation for current configuration options:
[https://docs.newrelic.com/docs/infrastructure/new-relic-infrastructure/configuration/configure-infrastructure-agent](https://docs.newrelic.com/docs/infrastructure/new-relic-infrastructure/configuration/configure-infrastructure-agent)

##### `nrinfragent_license_key`

##### `nrinfraintegrations_state` (OPTIONAL)

The state of the infrastructure integrations version pacakge. By default it's
`absent`, which doesn't install the package; you can change it to `latest` or
`present`.

###### DEPRECATED

Specify the license key. For backward compatibility. Use `license_key` in
`nrinfragent_config` instead. If both are specified the one in
`nrinfragent_config` will be used.

## Limitations

### Platforms

* RHEL
  * CentOS 7
  * CentOS 6
  * CentOS 5
* Ubuntu
  * 18 Bionic
  * 16 Xenial
  * 14 Trusty
  * 12 Precise
* Debian
  * 10 Buster
  * 9 Stretch
  * 8 Jessie
  * 7 Wheezy
* SUSE Linux Enterprise
  * 12

Copyright (c) 2018 New Relic, Inc. All rights reserved.
