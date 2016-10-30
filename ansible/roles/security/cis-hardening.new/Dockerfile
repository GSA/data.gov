# cis-ubuntu-ansible
#
# VERSION               1.0
FROM ubuntu:14.04
MAINTAINER Paul Chaignon <paul.chaignon@gmail.com>

ADD . /cis-ubuntu-ansible
WORKDIR /cis-ubuntu-ansible

RUN apt-get update
RUN apt-get -y install python-pip aptitude rsh-client rsh-redone-client talk avahi-daemon cups isc-dhcp-server ntp rpcbind nfs-kernel-server bind9 openssh-client openssh-server python-dev slapd nis libffi-dev libssl-dev
RUN pip install --upgrade setuptools ansible
RUN touch /etc/inetd.conf
RUN echo 'shell.bla' > /tmp/inetd
RUN cp /tmp/inetd /etc/inetd.conf
RUN echo 'start on runlevel [2345]' > /tmp/runxinit
RUN cp /tmp/runxinit /etc/init/xinetd.conf

RUN echo hello >> "hard'to\"quote$file"
RUN chown 1234:4321 "hard'to\"quote$file"
RUN cp tests/docker_defaults.yml vars/main.yml
RUN echo '[defaults]' > ansible.cfg
RUN echo 'roles_path = ../' >> ansible.cfg

RUN ansible-playbook -i tests/inventory tests/playbook.yml --syntax-check
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1 > results_indempotence.txt
RUN cat results_indempotence.txt
RUN cat results_indempotence.txt | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)




FROM ubuntu:12.04
MAINTAINER Paul Chaignon <paul.chaignon@gmail.com>

ADD . /cis-ubuntu-ansible
WORKDIR /cis-ubuntu-ansible

RUN apt-get update
RUN apt-get -y install python-pip aptitude rsh-client rsh-redone-client talk avahi-daemon cups isc-dhcp-server ntp rpcbind nfs-kernel-server bind9 openssh-client openssh-server python-dev slapd nis sudo libffi-dev
RUN pip install ansible
RUN touch /etc/inetd.conf
RUN echo 'shell.bla' > /tmp/inetd
RUN cp /tmp/inetd /etc/inetd.conf
RUN echo 'start on runlevel [2345]' > /tmp/runxinit
RUN cp /tmp/runxinit /etc/init/xinetd.conf

RUN echo hello >> "hard'to\"quote$file"
RUN chown 1234:4321 "hard'to\"quote$file"
RUN cp tests/docker_defaults.yml vars/main.yml
RUN echo '[defaults]' > ansible.cfg
RUN echo 'roles_path = ../' >> ansible.cfg

RUN ansible-playbook -i tests/inventory tests/playbook.yml --syntax-check
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1 > results_indempotence.txt
RUN cat results_indempotence.txt
RUN cat results_indempotence.txt | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)





FROM ubuntu:15.04
MAINTAINER Paul Chaignon <paul.chaignon@gmail.com>

ADD . /cis-ubuntu-ansible
WORKDIR /cis-ubuntu-ansible

RUN apt-get update
RUN apt-get -y install python-pip aptitude rsh-client rsh-redone-client talk avahi-daemon cups isc-dhcp-server ntp rpcbind nfs-kernel-server bind9 openssh-client openssh-server python-dev sudo libffi-dev libssl-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install slapd nis
RUN pip install --upgrade setuptools ansible
RUN touch /etc/inetd.conf
RUN echo 'shell.bla' > /tmp/inetd
RUN cp /tmp/inetd /etc/inetd.conf
RUN echo 'start on runlevel [2345]' > /tmp/runxinit
RUN cp /tmp/runxinit /etc/init/xinetd.conf

RUN echo hello >> "hard'to\"quote$file"
RUN chown 1234:4321 "hard'to\"quote$file"
RUN cp tests/docker_nofirewall_defaults.yml vars/main.yml
RUN echo '[defaults]' > ansible.cfg
RUN echo 'roles_path = ../' >> ansible.cfg

RUN ansible-playbook -i tests/inventory tests/playbook.yml --syntax-check
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1 > results_indempotence.txt
RUN cat results_indempotence.txt
RUN cat results_indempotence.txt | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)





FROM ubuntu:16.04
MAINTAINER Paul Chaignon <paul.chaignon@gmail.com>

ADD . /cis-ubuntu-ansible
WORKDIR /cis-ubuntu-ansible

RUN apt-get update
RUN apt-get -y install python-pip aptitude rsh-client rsh-redone-client talk avahi-daemon cups isc-dhcp-server ntp rpcbind nfs-kernel-server bind9 openssh-client openssh-server python-dev libffi-dev libssl-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install slapd nis
RUN pip install ansible
RUN touch /etc/inetd.conf
RUN echo 'shell.bla' > /tmp/inetd
RUN cp /tmp/inetd /etc/inetd.conf
RUN echo 'start on runlevel [2345]' > /tmp/runxinit
RUN cp /tmp/runxinit /etc/init/xinetd.conf

RUN echo hello >> "hard'to\"quote$file"
RUN chown 1234:4321 "hard'to\"quote$file"
RUN cp tests/docker_nofirewall_defaults.yml vars/main.yml
RUN echo '[defaults]' > ansible.cfg
RUN echo 'roles_path = ../' >> ansible.cfg

RUN ansible-playbook -i tests/inventory tests/playbook.yml --syntax-check
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1
RUN ansible-playbook -i tests/inventory tests/playbook.yml --connection=local --sudo -e "pipelining=True" -t level1 > results_indempotence.txt
RUN cat results_indempotence.txt
RUN cat results_indempotence.txt | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
