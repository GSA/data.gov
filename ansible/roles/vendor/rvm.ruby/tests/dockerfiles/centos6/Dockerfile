FROM centos:6

RUN yum update -y && \
		yum install -y \
			initscripts \
			sudo \
		&& yum clean all

RUN useradd -ms /bin/bash user \
		&& echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

CMD ["/sbin/init"]
