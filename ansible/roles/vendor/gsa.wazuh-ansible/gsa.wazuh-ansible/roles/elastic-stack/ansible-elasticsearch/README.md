Ansible Role: Elasticsearch
===========================

An Ansible Role that installs [Elasticsearch](https://www.elastic.co/products/elasticsearch).

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

Defaults variables are listed below, along with its values (see `defaults/main.yml`):

```
  elasticsearch_cluster_name: wazuh
  elasticsearch_node_name: node-1
  elasticsearch_http_port: 9200
  elasticsearch_network_host: 127.0.0.1
  elasticsearch_jvm_xms: 1g
  elastic_stack_version: 5.5.0
```

Example Playbook
----------------

```
  - hosts: elasticsearch
    roles:
      - { role: ansible-role-elasticsearch, elasticsearch_network_host: '192.168.33.182' }
```

License and copyright
---------------------

WAZUH Copyright (C) 2017 Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-elasticsearch

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
