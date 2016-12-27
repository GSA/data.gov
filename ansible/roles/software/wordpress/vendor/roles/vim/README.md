# Ansible Role: Vim & Vi-mode

[![Build Status](https://travis-ci.org/chusiang/vim-and-vi-mode.ansible.role.svg?branch=master)](https://travis-ci.org/chusiang/vim-and-vi-mode.ansible.role) [![Ansible Galaxy](https://img.shields.io/badge/role-vim--and--vi--mode-blue.svg)](https://galaxy.ansible.com/chusiang/vim-and-vi-mode/) [![Docker Hub](https://img.shields.io/badge/docker-vim--and--vi--mode-blue.svg)](https://hub.docker.com/r/chusiang/vim-and-vi-mode/) [![](https://images.microbadger.com/badges/image/chusiang/vim-and-vi-mode.svg)](https://microbadger.com/images/chusiang/vim-and-vi-mode "Get your own image badge on microbadger.com")


An Ansible role of Install Vim and use vi-mode in everyway.

## Requirements

None.

## Role Variables

None.

## Dependencies

None.

## Example Playbook

    - hosts: all
      roles:
        - { role: chusiang.vim-and-vi-mode }

## Docker Container

This repository contains Dockerized [Ansible](https://github.com/ansible/ansible), published to the public [Docker Hub](https://hub.docker.com/) via **automated build** mechanism.

> Docker Hub: [chusiang/vim-and-vi-mode](https://hub.docker.com/r/chusiang/vim-and-vi-mode/)

### Images

* chusiang/vim-and-vi-mode:ubuntu14.04 (lastest)
* chusiang/vim-and-vi-mode:ubuntu16.04
* chusiang/vim-and-vi-mode:debian7
* chusiang/vim-and-vi-mode:debian8
* chusiang/vim-and-vi-mode:centos6
* chusiang/vim-and-vi-mode:centos7

### Usage

    $ docker run -it -v /src:/data chusiang/vim-and-vi-mode:ubuntu14.04 bash
    root@a138a8d7ca3c:/tmp# vim --version
    VIM - Vi IMproved 7.4 (2013 Aug 10, compiled Jan  2 2014 19:39:32)
    ...

## License

Copyright (c) chusiang from 2016 under the MIT license.
