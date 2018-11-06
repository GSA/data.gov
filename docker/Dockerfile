FROM ubuntu:14.04

MAINTAINER John Jediny <john.jediny@gsa.gov>

#Install pre-reqs for Ansible
RUN apt-get -y install nano git software-properties-common

#Adding Ansible ppa
RUN apt-add-repository ppa:ansible/ansible

#Update apt-cache
RUN apt-get update

#Install Ansible
RUN apt-get -y install ansible

#Copy Ansible playbooks
COPY /ansible /etc/ansible

#Install Ansible role(s)
RUN ansible-galaxy install -r /etc/ansible/requirements.yml

#Run Ansible playbook
RUN ansible-playbook -c local /etc/ansible/main.yml

#Clean-up packages
RUN apt-get -y purge git ansible python-dev python-pip \
    apt-get -y clean && \
    apt-get -y autoremove

#Clean-up temp files
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Process start-up
CMD ["/bin/bash"]
