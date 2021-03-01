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
Ansible deploy           | <img src="https://img.shields.io/badge/status-complete-green.svg" />
Continuous Deployment    | <img src="https://img.shields.io/badge/status-complete-green.svg" />
Development environments | <img src="https://img.shields.io/badge/status-complete-green.svg" />
CKAN upgrade             | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Reduce maintenance scope | <img src="https://img.shields.io/badge/status-started-yellow.svg" />
Cloud migration          | <img src="https://img.shields.io/badge/status-started-yellow.svg" />


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

Moving to [cloud.gov](https://cloud.gov/) allows us to deploy with CI/CD with
immutable artifacts. We reduced the scope of maintenance by only being concerned
with the applications and not the underlying platform.
