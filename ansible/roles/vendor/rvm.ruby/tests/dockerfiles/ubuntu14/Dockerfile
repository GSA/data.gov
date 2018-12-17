FROM ubuntu:14.04

RUN apt-get update && \
		apt-get install -y \
			curl \
			build-essential \
			libbz2-dev \
			libffi-dev \
			libncurses5-dev \
			libreadline-dev \
			libssl-dev \
			sudo \
			wget \
		&& rm -rf /var/lib/apt/lists/*

WORKDIR /opt/
COPY build /opt/build
RUN  bash build

RUN useradd -ms /bin/bash user \
		&& echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

CMD ["/sbin/init"]
