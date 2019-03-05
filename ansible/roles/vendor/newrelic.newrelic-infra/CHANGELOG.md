# nrinfragent Ansible role CHANGELOG

This file is used to list changes made in each version of the `nrinfragent` Ansible role.

## 0.6.1 (2019-01-09)

BUG FIXES:

* Fix issue with Amazon Linux 2 install

## 0.6.0 (2018-11-23)

IMPROVEMENTS:

* Update README with better instructions for usage with Ansible Galaxy
* Installs the on-host integrations package for the Infrastructure agent
* Adds support for SUSE Linux Enterprise
* Adds support for Ubuntu Bionic
* Adds support for RHEL 5
* Fix error when specifying version number for the agent with
`nrinfragent_version`, it only worked with `nrinfragent_version: "*"` and
`nrinfragent_state: "latest"`

## 0.3.3 (2018-05-14)

BUG FIXES:

* Set default for license key

## 0.3.2 (2018-04-30)

IMPROVEMENTS:

* Replace Test Kitchen with Molecule

BUG FIXES:

* Fix Yum repository version for Amazon Linux

## 0.3.1 (2018-04-03)

BUG FIXES:

* Fix Yum repository URL for Amazon Linux

## 0.3.0 (2018-03-12)

IMPROVEMENTS:

* SUSE Linux support

## 0.2.0 (2018-01-29)

IMPROVEMENTS:

* Add `nrinfragent_config` to allow all available configuration options
* Move contents of agent.yml to main.yml

## 0.1.0 (2017-12-14)

IMPROVEMENTS:

* Initial tagged release.
