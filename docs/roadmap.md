# Roadmap

These are the near-term priorities for us:

- Keep our ansible playbooks and roles under version control with continuous
  integration tests
- Deploy to all of our environments (sandbox, dev, production, etc) via Ansible
- Deploy services as docker containers instead of configured instances
- Leverage Ansible Playbook Bundles to broker services automatically


Milestone | Status
--------- | ------
Continuous integration   | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Ansible deploy           | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Dockerize services       | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />
Ansible Playbook Bundles | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />


## Continuous Integration

[datagov-deploy](https://github.com/GSA/datagov-deploy) is a huge repo and
difficult to develop on. We're breaking out roles into individual repos that can
are easier to develop and test.

We're using [Kitchen](https://kitchen.ci/) to develop and test these roles
locally and on CI.


## Ansible deploy


## Dockerize services

We're using [docker-compose](https://docs.docker.com/compose/) for development
already. These docker images are published to [Docker
Hub](https://hub.docker.com/) where they can be composed together but are
currently for development only. We plan to move to a Docker-centric workflow
that allows us to deploy production services as Docker containers.


## Ansible Playbook Bundles

In the far distant future, we'd like to leverage [Ansible Playbook
Bundles](https://github.com/ansibleplaybookbundle/ansible-playbook-bundle) in
order to broker services automatically.
