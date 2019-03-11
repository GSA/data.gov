Ansible Role: Logstash
----------------------

An Ansible Role that installs [Logstash](https://www.elastic.co/products/logstash)

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
  logstash_create_config: true
  logstash_input_beats: false

  elasticsearch_network_host: "127.0.0.1"
  elasticsearch_http_port: "9200"
  elastic_stack_version: 5.5.0

  logstash_ssl: false
  logstash_ssl_dir: /etc/pki/logstash
  logstash_ssl_certificate_file: ""
  logstash_ssl_key_file: ""
```

Example Playbook
----------------

```
  - hosts: logstash
    roles:
      - { role: ansible-role-logstash, elasticsearch_network_host: '192.168.33.182' }
```

License and copyright
---------------------

WAZUH Copyright (C) 2017 Wazuh Inc. (License GPLv3)

### Based on previous work from geerlingguy

 - https://github.com/geerlingguy/ansible-role-elasticsearch

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
