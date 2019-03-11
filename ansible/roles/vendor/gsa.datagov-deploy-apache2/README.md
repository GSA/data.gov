[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy-apache2.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy-apache2)

# datagov-deploy-apache2

This project is part of [datagov-deploy](https://github.com/GSA/datagov-deploy).

Ansible role to deploy apache2 suitable for serving python-powered websites with
`mod_wsgi`.


## Usage

Include this role in your `requirements.yml`.

```yaml
- src: https://github.com/gsa/datagov-deploy-apache2.git
```

This role does not install any sites. You should copy your own site config files
and enable them with `a2ensite`.


### Variables

**`apache2_ssl_certificate_file`** string (default: none)

File path to the TLS/SSL certificate file.

**`apache2_ssl_certificate_key_file`** string (default: none)

File path to the TLS/SSL certificate key file.

**`apache2_ssl_ciphers`** string (default: `HIGH:!aNULL:!MD5`)

SSL cipher string to support for mod_ssl.

**`apache2_ssl_versions`** array<string> (default: `["TLSv1.1", "TLSv1.2"]`)

SSL versions to support for mod_ssl.

**`python_home`** (default: `/usr`)

The prefix path to where python is installed. If you installed your own version
of python, you might want to specify `/usr/local` or the path to your
virtualenv.


## Prerequisites for development

- [Docker](https://www.docker.com/)
- [Python](https://www.python.org/) 2.7 or 3.5+ in a virtualenv


## Development

Install dependencies.

    $ make setup

Run the tests.

    $ make test

To run the ssl scenario playbook with molecule.

    $ molecule converge -s ssl

For more information on how to use
[Molecule](https://molecule.readthedocs.io/en/latest/) for development, see [our
wiki](https://github.com/GSA/datagov-deploy/wiki/Developing-Ansible-roles-with-Molecule).
