[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy-postgresql.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy-postgresql)

# datagov-deploy-postgresql

Configures PostgreSQL database for an application. The role works with remote
database servers like AWS RDS. The database will be created with the role as the
owner.


## Usage

Install python dependencies.

    $ pip install psycopg2

Install the role with a requirements.yml.

```yaml
# requirements.yml
---
- src: https://github.com/GSA/datagov-deploy-postgresql
  version: v1.0.0
  name: gsa.datagov-deploy-postgresql
```

And install with ansible-galaxy.

    $ ansible-galaxy install -r requirements.yml

An example playbook.


```yaml
---
- name: install application
  roles:
    - role: gsa.datagov-deploy-postgresql
```


### Variables

**`postgresql_app_name`** string

The name of your application which will be used as a default for the database
name, role, and other configuration.


**`postgresql_role_password`** string **required**

The password to set on the database role, used for your app to login to the
database.


**`postgresql_role_name`** string (default: `{{ postgresql_app_name }}`)

Explicitly set the database role name to create.


**`postgresql_database_name`** string (default: `{{ postgresql_app_name }}`)

The name of the database to create.


**`postgresql_login_host`** string (default: `localhost`)

The remote host where the database will be created.


**`postgresql_login_user`** string (default: `postgres`)

The master database user with superuser permissions to login as. This user is
used by the role to create and configure the database. It should **not** be your
app user.


**`postgresql_login_password`** string

The master password to use to login to the PostgreSQL host.


**`postgresql_enable_extensions`** list (default: `[]`)

List of PostgreSQL database extensions to enable, e.g. postgis.



## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.


## Development

Install dependencies.

    $ pipenv install

Run the playbook with molecule.

    $ pipenv run molecule converge

Run the tests.

    $ pipenv run molecule test

For more information on how to use
[Molecule](https://molecule.readthedocs.io/en/latest/) for development, see [our
wiki](https://github.com/GSA/datagov-deploy/wiki/Developing-Ansible-roles-with-Molecule).


## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in
[CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright
> and related rights in the work worldwide are waived through the [CC0 1.0
> Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication.
> By submitting a pull request, you are agreeing to comply with this waiver of
> copyright interest.
