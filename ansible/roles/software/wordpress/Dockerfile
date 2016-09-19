FROM ubuntu:14.04

MAINTAINER datagov@gsa.gov

RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get install -y sudo

RUN mkdir /var/run/sshd

ENV USER ubuntu

RUN adduser --disabled-password --gecos "" $USER
RUN adduser $USER sudo
RUN adduser $USER www-data

ADD authorized_keys /home/$USER/.ssh/authorized_keys

RUN chown -R $USER:$USER /home/$USER/.ssh
RUN chmod -R 700 /home/$USER/.ssh


# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
      /etc/sudoers

ADD docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
CMD ["/usr/local/bin/docker_entrypoint.sh"]

#CMD ["/usr/sbin/sshd", "-D"]