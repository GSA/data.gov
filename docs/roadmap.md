# Roadmap

Data.gov follows the four principles of modern [Release Engineering](https://en.wikipedia.org/wiki/Release_engineering):

* **Identifiability** Being able to identify all of the source, tools, environment, and other components that make up a particular release.
* **Reproducibility** The ability to integrate source, third party components, data, and deployment externals of a software system in order to guarantee operational stability.
* **Consistency** The mission to provide a stable framework for development, deployment, audit, and accountability for software components.
* **Agility** The ongoing research into what are the repercussions of modern software engineering practices on the productivity in the software cycle, i.e. continuous integration.


## Goals

- Implement modern DevOps best practices (e.g. Continuous Integration, Continuous Deployment, Configuration and Infrastructure as Code)
- Keep close parity with upstream projects and avoid forks
- Leverage user-centered design for determining team priorities


## Milestones

These are the near-term priorities for us:

- Keep our ansible playbooks and roles under version control with continuous
  integration tests
- Deploy to all of our environments (sandbox, staging, production, etc) via Ansible
- Deploy services as docker containers instead of configured instances


Milestone | Status
--------- | ------
Continuous integration   | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Ansible deploy           | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Dockerize services       | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />


### Continuous Integration

[datagov-deploy](https://github.com/GSA/datagov-deploy) is a huge repo and
difficult to develop on. We're breaking out roles into individual repos that can
are easier to develop and test.

We're using [Molecule](https://molecule.readthedocs.io/en/stable/) to develop and test these roles
locally and on CI.


### Ansible deploy

We use [Ansible](https://www.ansible.com/) to deploy our platform and the Data.gov applications that run on top. Deployment of the platform should work from a single command/playbook.

Deployment of individual applications can be done with playbook or Ansible tag.


### Dockerize services

We're using [docker-compose](https://docs.docker.com/compose/) for development
already. These docker images are published to [Docker
Hub](https://hub.docker.com/) where they can be composed together but are
currently for development only. We plan to move to a Docker-centric workflow
that allows us to deploy production services as Docker containers.
