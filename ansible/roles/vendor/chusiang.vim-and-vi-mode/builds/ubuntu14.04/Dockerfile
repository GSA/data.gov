# Dockerfile for building image that contains software stack provisioned by Ansible.

FROM williamyeh/ansible:ubuntu14.04-onbuild
MAINTAINER Chu-Siang Lai <chusiang@drx.tw>

# @see http://www.monblocnotes.com/node/2057
# @see http://askubuntu.com/a/365912
RUN echo "===> Fix policy-rc.d for Docker ..."  && \
      sed -i -e 's/exit\s\s*101/exit 0/' /usr/sbin/policy-rc.d

RUN echo "===> Install necessary packages ..."  && \
      apt-get install -y curl git make

RUN echo "===> Get playbook ..."  && \
      git clone --depth=1 https://github.com/chusiang/vim-and-vi-mode.ansible.role.git ;\
      cd vim-and-vi-mode.ansible.role

ENV PLAYBOOK vim-and-vi-mode.ansible.role/provision.yml

RUN echo "===> Run playbook ..."  && \
      ansible-playbook-wrapper

RUN echo "===> Clean ..."  && \
      apt-get clean

WORKDIR /srv
CMD [ "vim", "--version" ]

# For run as daemon (service).
ADD https://raw.githubusercontent.com/chusiang/vim-and-vi-mode.ansible.role/master/files/run.sh /usr/local/bin/
