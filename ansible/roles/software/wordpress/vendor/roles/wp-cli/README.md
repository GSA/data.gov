Ansible Role: WP-CLI
=======================

[![Build Status](https://travis-ci.org/heskethm/ansible-role-wp-cli.svg)](https://travis-ci.org/heskethm/ansible-role-wp-cli)

Ansible role for installing WP-CLI, a command line interface for WordPress.

Installation
------------

```
$ ansible-galaxy install heskethm.wp-cli
```

Role Variables
--------------

All available variables and default values are listed below. You may override these in your Playbook, `group_vars`, command line etc.

```yml
wp_cli_phar_url: https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
```

Location of the WP-CLI phar to download.

```yml
wp_cli_bin_path: /usr/bin/wp
```

Location to store WP-CLI on remote machine.

Dependencies
------------

None

Example Playbook
----------------

```yml
- hosts: web
  roles:
     - { role: heskethm.wp-cli }
```

Author
------------------

* Web: [markhesketh.co.uk](http://www.markhesketh.co.uk/)
* Email: [contact@markhesketh.co.uk](mailto:contact@markhesketh.co.uk)
* Twitter: [twitter.com/markyhesketh](http://www.twitter.com/markyhesketh/)
* Github: [github.com/heskethm](http://www.github.com/heskethm/)

License
-------

[MIT](http://opensource.org/licenses/MIT)