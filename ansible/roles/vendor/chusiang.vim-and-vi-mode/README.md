# Ansible Role: Vim & Vi-mode

[![Build Status](https://travis-ci.org/chusiang/vim-and-vi-mode.ansible.role.svg?branch=master)](https://travis-ci.org/chusiang/vim-and-vi-mode.ansible.role) [![Ansible Galaxy](https://img.shields.io/badge/role-vim--and--vi--mode-blue.svg)](https://galaxy.ansible.com/chusiang/vim-and-vi-mode/) [![Docker Hub](https://img.shields.io/badge/docker-vim--and--vi--mode-blue.svg)](https://hub.docker.com/r/chusiang/vim-and-vi-mode/) [![](https://images.microbadger.com/badges/image/chusiang/vim-and-vi-mode.svg)](https://microbadger.com/images/chusiang/vim-and-vi-mode "Get your own image badge on microbadger.com")

An Ansible role of Install Vim and use vi-mode in everyway.

1. Install Vim.
1. Switch default editor to Vim.
1. Use vi-mode in Bash, Readline and Git.

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

* chusiang/vim-and-vi-mode:ubuntu16.04 (lastest)
* chusiang/vim-and-vi-mode:ubuntu14.04
* chusiang/vim-and-vi-mode:debian9
* chusiang/vim-and-vi-mode:debian8
* ~~chusiang/vim-and-vi-mode:debian7~~ (EOL)
* chusiang/vim-and-vi-mode:centos7
* ~~chusiang/vim-and-vi-mode:centos6~~ (EOL)
* chusiang/vim-and-vi-mode:alpine3

### Usage

#### Normal mode

Run container.

```
$ docker run -it -v $PWD:/srv chusiang/vim-and-vi-mode:debian9 bash
root@a138a8d7ca3c:/tmp# vim --version
VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Sep 30 2017 18:21:38)
...
```

#### Daemon (service) mode

1. Run container as service.

    ```
    $ docker run --name vim -d -v $PWD:/srv chusiang/vim-and-vi-mode:debian9 run.sh
    4f4abc41abff3e4dbd37145fafd84a43de0230599883ebd82249b778ea1994c6
    ```

1. Enter the container.

    ```
    $ docker exec -it vim bash
    ```

## License

Copyright (c) chusiang from 2016-2018 under the MIT license.
