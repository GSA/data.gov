# ansible-td-agent

This ansible role installs the td-agent, the distribution of [fluentd](http://fluentd.org/).

This role is written based on [the official installation page](http://docs.fluentd.org/categories/installation)

## Requirements

This role requires Ansible 1.4 higher and platforms listed in the metadata file.

## Role Variables

The variables that can be passed to this role **when the OS is Debian** and a brief description about them are as follows

    # The version of td-agent (optional)
    td_agent_version: 1.1.18-1

    # Architecture of the machine (required, i386 or amd64)
    td_agent_architecture: amd64

You can also pass in a list of plugins to be installed using tg-agent-gem as follows:

    td_agent_plugins:
    - 'fluent-plugin-secure-forward'
    - 'fluent-plugin-...'

Detail for [the official intallation page](http://docs.fluentd.org/articles/install-by-deb)

## Examples

1) Ubuntu or EL

    ---
    - hosts: all
      roles:
        - td-agent

2) Debian (define only architecture)

    ---
    - hosts: all
      roles:
        - role: td-agent
          td_agent_architecture: i386

3) Debian (define architecture and td_agent_version)

    ---
    - hosts: all
      roles:
        - role: td-agent
          td_agent_architecture: amd64
          td_agent_version: 1.1.17-1


## Plugins

* fluentd-plugin-cloudwatch-log  Based off of [this gem](https://github.com/ryotarai/fluent-plugin-cloudwatch-logs), we make the following modificiations
  * Change single line in /etc/init.d/td-agent to ensure AWS_REGION is set (this is required by the plugin)
  * Modify /opt/td-agent/td-agent.conf to include test input/output to CloudWatch Logs
  * Change the permissions on the ruby gem to 775
  * Restart the td-agent service

## Dependencies

None

## Licence

BSD

## Contribution

Fork and make pull request!

[kawasakitoshiya / ansible-td-agent](https://github.com/kawasakitoshiya/ansible-td-agent)

## Author Information

Toshiya Kawasaki
