# Fluentd td-agent setup ansible role

## Provides

* td-agent
* td-agent-plugins
* [kernel & file configuration](http://docs.fluentd.org/articles/before-install)

## Usage

  roles:
    - monitoring/fluentd/td-agent
    - monitoring/fluentd/limits
    - monitoring/fluentd/kernel
