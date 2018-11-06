FROM ubuntu:14.04
MAINTAINER Data.gov

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python \
       sudo \
       bash \
       ca-certificates \
    && apt-get clean

# Create ubuntu user
RUN useradd -m ubuntu -G sudo

USER ubuntu
