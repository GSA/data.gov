FROM ubuntu:16.04
MAINTAINER Data.gov

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python-software-properties \
       software-properties-common \
       rsyslog systemd systemd-cron sudo \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

#ADD etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Install Ansible
RUN add-apt-repository -y ppa:ansible/ansible \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     ansible \
  && rm -rf /var/lib/apt/lists/* \
  && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
  && apt-get clean

# Install Ansible inventory file
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Prime CMD to accept playbook as var
CMD [ "ansible-playbook", "--version" ]