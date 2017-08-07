# What's here?

## Ansible Roles <img src="https://img.shields.io/badge/Implementation%20Status-Prod-blue.svg" />

**See Main [README](https://github.com/gsa/datagov-deploy)**

## Ansible Container <img src="https://img.shields.io/badge/Implementation%20Status-WIP-red.svg" /> 

[Ansible Container](https://github.com/ansible/ansible-container) provides a convenient way to develop and test playbooks using Docker:

* `ansible-container build` - initiates the build process. It uses an Ansible Container Builder container and also runs instances of your base container images as specified in container.yml. The Builder container runs the playbook main.yml against them, committing the results as new images. Ansible communicates with the other containers through the container engine, not through SSH.
* `ansible-container run` - orchestrates containers from your built images together as described by the container.yml file. In your development environment, the container.yml can specify overrides to make development faster without having to rebuild images for every code change.
* `ansible-container push` - uploads your built images to a container registry of your choice.
* `ansible-container shipit` - generates an Ansible Role to orchestrate containers from your built images in production container platforms, like Kubernetes or Red Hat OpenShift.
