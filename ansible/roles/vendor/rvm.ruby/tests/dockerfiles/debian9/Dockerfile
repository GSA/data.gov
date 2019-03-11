FROM debian:9

RUN apt-get update && \
    apt-get install -y \
			curl \
			gpg \
			python \
			sudo \
			systemd \
		&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user \
		&& echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

CMD ["/bin/systemd"]
