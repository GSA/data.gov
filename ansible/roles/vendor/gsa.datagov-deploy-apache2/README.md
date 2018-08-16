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

**`python_home`** (default: `/usr`)

The prefix path to where python is installed. If you installed your own version
of python, you might want to specify `/usr/local` or the path to your
virtualenv.


## Prerequisites for development

- [Ruby](https://www.ruby-lang.org/) 2.3+
- [Docker](https://www.docker.com/)
- [Python](https://www.python.org/) 2.7 or 3.5+ in a virtualenv


## Development

Install dependencies.

    $ make setup

Run the tests.

    $ make test

You can debug the container after it runs. See `kitchen help` for additional
commands.

    $ bundle exec kitchen login
