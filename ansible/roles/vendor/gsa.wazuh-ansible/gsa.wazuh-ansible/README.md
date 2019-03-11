# Wazuh-Ansible 

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/wazuh)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

[![CircleCI](https://circleci.com/gh/GSA/wazuh-ansible.svg?style=svg)](https://circleci.com/gh/GSA/wazuh-ansible)

These playbooks install and configure Wazuh agent, manager and Elastic Stack.

## Documentation

* [Wazuh Ansible documentation](https://documentation.wazuh.com/current/deploying-with-ansible/index.html)
* [Full documentation](http://documentation.wazuh.com)

## Directory structure

    ├── wazuh-ansible
    │ ├── roles
    │ │ ├── elastic-stack 
    │ │ │ ├── ansible-elasticsearch        
    │ │ │ ├── ansible-logstash
    │ │ │ ├── ansible-kibana
    │ │
    │ │ ├── wazuh                
    │ │ │ ├── ansible-filebeat
    │ │ │ ├── ansible-wazuh-manager
    │ │ │ ├── ansible-wazuh-agent
    │ │
    │ │ ├── ansible-galaxy
    │ │ │ ├── meta
    │
    │ ├── playbooks
    │ │ ├── wazuh-agent.yml
    │ │ ├── wazuh-elastic.yml
    │ │ ├── wazuh-elastic_stack-distributed.yml
    │ │ ├── wazuh-elastic_stack-single.yml
    │ │ ├── wazuh-kibana.yml
    │ │ ├── wazuh-logstash.yml
    │ │ ├── wazuh-manager.yml
    │
    │ ├── README.md
    │ ├── VERSION
    │ ├── CHANGELOG.md


## Branches

* `stable` branch on correspond to the last Wazuh-Ansible stable version.
* `master` branch contains the latest code, be aware of possible bugs on this branch.

## Testing
```
pip install pipenv
sudo pipenv install
pipenv run test
```

## Contribute

If you want to contribute to our repository, please fork our Github repository and submit a pull request.

If you are not familiar with Github, you can also share them through [our users mailing list](https://groups.google.com/d/forum/wazuh), to which you can subscribe by sending an email to `wazuh+subscribe@googlegroups.com`. 

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.

## Credits and Thank you

Based on previous work from dj-wasabi.

https://github.com/dj-wasabi/ansible-ossec-server

## License and copyright

WAZUH
Copyright (C) 2016-2018 Wazuh Inc.  (License GPLv2)

## Web references

* [Wazuh website](http://wazuh.com)
