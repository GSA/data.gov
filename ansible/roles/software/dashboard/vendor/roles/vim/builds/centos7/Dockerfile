# Dockerfile for building image that contains software stack provisioned by Ansible.
#
# USAGE:
#   $ docker build -t vim:centos7 .
#
# Version  1.1
#

# pull base image
FROM williamyeh/ansible:centos7-onbuild
MAINTAINER Chu-Siang Lai <chusiang.lai@gmail.com>

#
# build phase
#

# init.
RUN yum install -y curl git make ;\
      git clone https://github.com/chusiang/vim-and-vi-mode.ansible.role.git ;\
      cd vim-and-vi-mode.ansible.role
      
ENV PLAYBOOK vim-and-vi-mode.ansible.role/setup.yml
RUN ansible-playbook-wrapper -vvv

