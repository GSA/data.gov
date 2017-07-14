# ansible-logrotate

logrotate - rotates, compresses, and mails system logs

[![Platforms](http://img.shields.io/badge/platforms-ubuntu-lightgrey.svg?style=flat)](#)

Forked form telusdigital because we need to depend on released versions of roles.

Tunables
--------
* ```logrotate_name``` (string) - Name for logrotate script
* ```logrotate_log_path``` (string) - Path for log to rotate
* ```logrotate_create_logs_with_mode``` (string) - mode to create empty logfile with
* ```logrotate_create_logs_with_owner``` (string) - owner for new logfile after rotation
* ```logrotate_create_logs_with_group``` (string) - group for new logfile after rotation
* ```logrotate_ignore_empty_logs``` (string) - Do not rotate logs if they are empty
* ```logrotate_ignore_missing_logs``` (string) - Do not complain if logs are missing
* ```logrotate_compression``` (string) - Compress logs after rotation?
* ```logrotate_postpone_compression``` (string) - Compress logs the day after rotation?
* ```logrotate_frequency``` (string) - How often to rotate logs?
* ```logrotate_retention_limit``` (integer) - How many old logs to retain?
* ```logrotate_notify_pidfile``` (string) - Pidfile of process to signal when rotation is complete
* ```logrotate_notify_signal``` (string) - Signal to send when to process when rotation is complete
* ```logrotate_prerotate_commands``` (list) - Commands to execute prior to rotation
* ```logrotate_postrotate_commands``` (list) - Commands to execute after rotation

Dependencies
------------
* [telusdigital.apt-repository](https://github.com/telusdigital/ansible-apt-repository/)

Example Playbook
----------------
    - hosts: servers
      roles:
         - role: telusdigital.logrotate
           logrotate_name: nginx

License
-------
[MIT](https://tldrlegal.com/license/mit-license)

Contributors
------------
* [Aaron Pederson](https://aaronpederson.github.io) | [e-mail](mailto:aaronpederson@gmail.com) | [Twitter](https://twitter.com/GunFuSamurai) 
* [Chris Olstrom](https://colstrom.github.io/) | [e-mail](mailto:chris@olstrom.com) | [Twitter](https://twitter.com/ChrisOlstrom)
