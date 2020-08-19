# Roadmap

## Goals

- Implement Continuous Deployment for the platform and all applications.
- Implement first-class development environments for all Data.gov code
  repositories.
- Migrate to an immutable platform that supports twelve-factor applications.
- Keep close parity with upstream projects and reduce the number of forks we
  maintain.
- Leverage user-centered design for determining team priorities.


## Milestones

These are the near-term priorities for us that will achieve the above goals.

Milestone | Status
--------- | ------
Continuous Integration   | <img src="https://img.shields.io/badge/status-complete-green.svg" />
Ansible deploy           | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Continuous Deployment    | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Development environments | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />
CKAN upgrade             | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />
Reduce maintenance scope | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />
Cloud migration          | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />
Dockerize services       | <img src="https://img.shields.io/badge/status-not_started-lightgrey.svg" />


### Continuous Integration

[datagov-deploy](https://github.com/GSA/datagov-deploy) is a huge repo and
difficult to develop on. We're breaking out roles into individual repos that can
are easier to develop and test.

We're using [Molecule](https://molecule.readthedocs.io/en/stable/) to develop
and test these roles locally and on CI.


### Ansible deploy

We use [Ansible](https://www.ansible.com/) to deploy our platform and the
Data.gov applications that run on top. Deployment of the platform should work
from a single command/playbook.

Deployment of individual applications can be done with playbook or Ansible tag.


### Continuous Deployment

Any change to an application's repository triggers a deployment. `develop`
branch is deployed to the sandbox environment. `master` branch will be deployed
to staging and production environments.


### First-class development environments

Application development and debugging can be done locally. Setup is documented
and automated using virtualization like Vagrant or docker-compose. Automated
unit and integration tests exist and are running as part of Continuous
Integration.


### CKAN upgrade

A clean switch-over to a modern version of CKAN. Data.gov contains many forks
and customizations. Why do these customizations exist? Are they still necessary
based on business and user needs?

Instead of porting over each CKAN extension and pushing fixes upstream, let's
start with a clean CKAN install and build out features based on user needs
though a user-research and discovery.

Old forks and customizations can be archived if not explicitly required by user
needs.


### Reduce maintenance scope

Reduce the number of forks and code that we maintain. Push fixes upstream where
possible.


### Cloud migration

Infrastructure environments are created from [Infrastructure as
Code](https://github.com/GSA/datagov-infrastructure-live) via the CI/CD
pipeline.

Immutable artifacts for applications can be deployed automatically by CI/CD
pipeline.

Platform is able to scale dynamically based on demand.


### Dockerize services

We're using [docker-compose](https://docs.docker.com/compose/) for development
already. These docker images are published to [Docker
Hub](https://hub.docker.com/) where they can be composed together but are
currently for development only. We plan to move to a Docker-centric workflow
that allows us to deploy production services as Docker containers.
