# Ansible Role: WP-CLI

[![Build Status](https://travis-ci.org/sbaerlocher/ansible.wp-cli.svg?branch=master)](https://travis-ci.org/sbaerlocher/ansible.wp-cli) [![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://sbaerlo.ch/licence) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-wp-cli-blue.svg)](https://galaxy.ansible.com/sbaerlocher/wp-cli)

## Description

Ansible role for installing WP-CLI, a command line interface for WordPress.

## Installation

```bash
ansible-galaxy install sbaerlocher.wp-cli
```

## Requirements

None

## Role Variables

| Variable             | Default     | Comments (type)                                   |
| :---                 | :---        | :---                                              |
| ```wp_cli_phar_url``` | ```https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar``` | Location of the WP-CLI phar to download |
| ```wp_cli_bin_path``` | ```/usr/bin/{{ wp_cli_bin_command }}``` | Location to store WP-CLI on remote machine |
| ```wp_cli_bin_command``` | wp | WP-CLI Coomand on remote machine |
| ```wp_cli_packages```  |  | List of WP-CLI packages for Installing |

## Dependencies

None

## Example Playbook

```yml
- hosts: all
  roles:
     - sbaerlocher.wp-cli
```

## Changelog

### 1.3

* new role test

### 1.2

* add WP-CLI package installer

### 1.1

* add travis
* fix travis problems

### 1.0

* Initial release

## Author

* [Simon Bärlocher](https://sbaerlocher.ch)

## License

This project is under the MIT License. See the [LICENSE](https://sbaerlo.ch/licence) file for the full license text.

## Copyright

(c) 2018, Simon Bärlocher
