## logrotated

[![Build Status](https://travis-ci.org/Oefenweb/ansible-logrotated.svg?branch=master)](https://travis-ci.org/Oefenweb/ansible-logrotated) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-logrotated-blue.svg)](https://galaxy.ansible.com/tersmitten/logrotated)

Manage logrotated.d in Debian-like systems.

#### Requirements

None

#### Variables

* `logrotated_logrotate_d_files` [default: `{}`]: `/etc/logrotated.d/*` A list of application-specific file declarations
* `logrotated_logrotate_d_files.key`: The name of the logrotated configuration file (e.g `apache2`)
* `logrotated_logrotate_d_files.key.{n}` [optional, default: `[]`]: A section declaration
* `logrotated_logrotate_d_files.key.{n}.logs` [default: `[]`]: The log files for this section
* `logrotated_logrotate_d_files.key.{n}.size` [optional]: Rotate logs when they reach this size
* `logrotated_logrotate_d_files.key.{n}.daily` [optional]: Whether or not log files are rotated every day
* `logrotated_logrotate_d_files.key.{n}.weekly` [optional]: Whether or not log files are rotated weekly
* `logrotated_logrotate_d_files.key.{n}.monthly` [optional]: Whether or not log files are rotated monthly
* `logrotated_logrotate_d_files.key.{n}.yearly` [optional]: Whether or not log files are rotated yearly
* `logrotated_logrotate_d_files.key.{n}.missingok` [optional]: Whether or not to go on to the next log file without issuing an error message when the  log  file is missing
* `logrotated_logrotate_d_files.key.{n}.rotate` [optional]: Number of times log files are rotated (before being removed)
* `logrotated_logrotate_d_files.key.{n}.compress` [optional]: Whether or not old versions of log files are compressed
* `logrotated_logrotate_d_files.key.{n}.delaycompress` [optional]: Whether or not to postpone compression of the previous log file to the next rotation cycle
* `logrotated_logrotate_d_files.key.{n}.copytruncate` [optional]: Whether or not to truncate the original log file to zero size in place after creating a copy
* `logrotated_logrotate_d_files.key.{n}.notifempty` [optional]: Whether or not to not rotate the log if it is empty
* `logrotated_logrotate_d_files.key.{n}.create` [optional]: Whether or not the log file is created immediately after rotation wit the given mode, owner and group
* `logrotated_logrotate_d_files.key.{n}.sharedscripts` [optional]: Whether or not the scripts are only run once, no matter how many logs match the wildcarded  pattern
* `logrotated_logrotate_d_files.key.{n}.scripts` [optional, default: `{}`]: A hash of scripts
* `logrotated_logrotate_d_files.key.{n}.scripts.key` [required]: Action to run the script (e.g `postrotate`)
* `logrotated_logrotate_d_files.key.{n}.scripts.key.{n}` [default: `[]`]: List of lines with directives to execute

## Dependencies

None

#### Example(s)

##### Simple configuration

```yaml
---
- hosts: all
  roles:
    - logrotated
```

##### Complex configuration

```yaml
---
- hosts: all
  roles:
    - logrotated
  vars:
    logrotated_logrotate_d_files:
      apache2:
        - logs:
            - '/var/log/apache2/*.log'
          weekly: true
          missingok: true
          rotate: 52
          compress: true
          delaycompress: true
          notifempty: true
          create: '640 root adm'
          sharedscripts: true
          scripts:
            postrotate:
              - 'if /etc/init.d/apache2 status > /dev/null ; then \'
              - '  /etc/init.d/apache2 reload > /dev/null; \'
              - 'fi;'
            prerotate:
              - 'if [ -d /etc/logrotate.d/httpd-prerotate ]; then \'
              - '  run-parts /etc/logrotate.d/httpd-prerotate; \'
              - 'fi;'
```

#### License

MIT

#### Author Information

* Mark van Driel
* Mischa ter Smitten

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Oefenweb/ansible-logrotated/issues)!
