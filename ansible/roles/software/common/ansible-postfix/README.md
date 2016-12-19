## postfix

[![Build Status](https://travis-ci.org/Oefenweb/ansible-postfix.svg?branch=master)](https://travis-ci.org/Oefenweb/ansible-postfix) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-postfix-blue.svg)](https://galaxy.ansible.com/list#/roles/1400)

Set up a postfix server in Debian-like systems.

#### Requirements

None

#### Variables

 * `postfix_install` [default: `[postfix, mailutils, libsasl2-2, sasl2-bin, libsasl2-modules]`]: Packages to install
 * `postfix_hostname` [default: `{{ ansible_fqdn }}`]: Host name, used for `myhostname` and in `mydestination`
 * `postfix_mailname` [default: `{{ ansible_fqdn }}`]: Mail name (in `/etc/mailname`), used for `myorigin`
 * `postfix_aliases` [default: `[]`]: Aliases to ensure present in `/etc/aliases`
 * `postfix_mynetworks` [default: `['127.0.0.0/8', '[::ffff:127.0.0.0]/104', '[::1]/128']`]: The list of "trusted" remote SMTP clients that have more privileges than "strangers"
 * `postfix_inet_interfaces` [default: `all`]: Network interfaces to bind ([see](http://www.postfix.org/postconf.5.html#inet_interfaces))
 * `postfix_inet_protocols` [default: `all`]: The Internet protocols Postfix will attempt to use when making or accepting connections ([see](http://www.postfix.org/postconf.5.html#inet_protocols))
 * `postfix_sasl_auth_enable` [default: `true`]: Enable SASL authentication in the SMTP client
 * `postfix_relayhost` [default: `false` (no relay host)]: Hostname to relay all email to
 * `postfix_relayhost_port` [default: 587]: Relay port (on `postfix_relayhost`, if set)
 * `postfix_sasl_security_options` [default: `noanonymous`]: SMTP client SASL security options
 * `postfix_relaytls` [default: `false`]: Use TLS when sending with a relay host
 * `postfix_sasl_user` [default: `postmaster@{{ ansible_domain }}`]: SASL relay username
 * `postfix_sasl_password` [default: `k8+haga4@#pR`]: SASL relay password **Make sure to change!**
 
## Dependencies

* `debconf`
* `debconf-utils`

#### Example

A simple example that doesn't use SASL relaying:
```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    postfix_aliases:
      - { user: root, alias: you@yourdomain.org }
```

Provide the relay host name if you want to enable relaying:
```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    postfix_aliases:
      - { user: root, alias: you@yourdomain.org }
    postfix_relayhost: mail.yourdomain.org
```

For AWS SES support:
```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    postfix_aliases:
      - { user: root, alias: sesverified@yourdomain.org }
    postfix_relayhost: email-smtp.us-east-1.amazonaws.com
    postfix_relaytls: true
    # AWS IAM SES credentials (not access key):
    postfix_sasl_user: AKIXXXXXXXXXXXXXXXXX
    postfix_sasl_password: ASDFXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

For MailHog support:
```yaml
---
- hosts: all
  roles:
    - postfix
  vars:
    postfix_aliases:
      - { user: root, alias: you@yourdomain.org }
    postfix_relayhost: "{{ ansible_lo['ipv4']['address'] }}"
    postfix_relayhost_port: 1025
    postfix_sasl_auth_enable: false
```

#### License

MIT

#### Author Information

Mischa ter Smitten

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Oefenweb/ansible-postfix/issues)!
