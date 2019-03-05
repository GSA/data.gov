Filebeat agent
=========
[![CircleCI](https://circleci.com/gh/GSA/ansible-role-beats.svg?style=svg)](https://circleci.com/gh/GSA/ansible-role-beats)

This role installs [Beats](https://www.elastic.co/products/beats) products on a Ubuntu machine.

This role is capable of installing *all* beats products available as deb packages. However, for configuring beats products (e.g filebeat.yml, metricbeat.yml) the only supported products so far are:

- filebeat
- metricbeat

Requirements
------------

None

Role Variables
--------------

You should specify the version for the Beats products you want to install with the `beats_ver` variable (default: 6.2.2).

You also need to specify the products you want to install in a list variable called `products`:
``` yaml
products:
  - filebeat
  - metricbeat
```

If you want to also configure the products on the fly you will need to create a variable with the product name plus `_config:` which should be a dictionary containing the YAML config for the product you choose. E.G:

``` yaml
filebeat_config:
  filebeat.modules:
    - module: system
      syslog:
        enabled: true
  output.logstash.hosts:
    - logstash.server:5044
```
The specific values for the configuration are well described in the beats documentation


Dependencies
------------

There is no dependencies

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: jobscore.beats
           products:
            - filebeat
            - metricbeat
            - heartbeat

License
-------

GPLv3

Author Information
------------------

This role was created by [Eric Magalhães](https://emagalha.es)
