#!/usr/bin/env bash

service php7.0-fpm start
service nginx start
/usr/sbin/sshd -D