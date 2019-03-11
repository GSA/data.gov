Ansible Role: Kibana for Elastic Stack
------------------------------------

An Ansible Role that installs [Kibana](https://www.elastic.co/products/kibana) and [Wazuh APP](https://github.com/wazuh/wazuh-kibana-app).

Requirements
------------

This role will work on:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu

Role Variables
--------------

```
---
  elasticsearch_http_port: "9200"
  elasticsearch_network_host: "127.0.0.1"
  kibana_server_host: "0.0.0.0"
  kibana_server_port: "5601"
  elastic_stack_version: 5.5.0
```

Example Playbook
----------------

```
  - hosts: kibana
    roles:
      - { role: ansible-role-kibana, elasticsearch_network_host: '192.168.33.182' }
```

License and copyright
---------------------

WAZUH Copyright (C) 2017 Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-elasticsearch

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
