# Docker images for test

These files are used to create docker images that are used in testing as base
images for kitchen and molecule.

The Dockerfiles create Ansible-compatible container images that can be used with
Ansible's docker connection.

The Makefile contains rules to create the platform images (the base Ubuntu
images) on which the other images are based.

`docker-playbook.sh` starts the docker container, runs a specific playbook with
the specified arguments, and saves the resulting container image.

## make targets

**all** (default)

Makes all the platform images and then all the base images. Most of the time you
should just run this.

**ubuntu1404-ansible**

Builds the Ubuntu 14.04 platform image.

**catalog-base-ubuntu1404-ansible**

Builds the catalog base image for the Ubuntu 14.04 platform.


## Publishing images

_TODO: we should add a special make target to push the images to docker hub._
