FROM python:3.6-alpine

ARG APP_UID=1000
ARG APP_GID=1000

# Configure pipenv to install to the project directory
ENV PIPENV_VENV_IN_PROJECT=1

# Ignore host keys
ENV ANSIBLE_HOST_KEY_CHECKING=False

# Install build dependencies
RUN apk add \
  gcc \
  git \
  libc-dev \
  libffi-dev \
  make \
  openssl-dev \
  pkgconfig

# Copy ansible and dependency files
COPY Makefile Pipfile Pipfile.lock /app/
COPY ansible/ /app/ansible/

# Install python dependencies and ansible role dependencies
WORKDIR /app
RUN pip install pipenv && pipenv sync
RUN pipenv run make vendor

RUN addgroup -S -g $APP_GID app && adduser -S -G app -u $APP_UID app
USER app
WORKDIR /app/ansible
