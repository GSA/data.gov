[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy-mysql.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy-mysql)

# datagov-deploy-mysql

Configures mysql server with for a Data.gov application including an app
database and user.


## Usage

```yaml
---
- name: create application database
  hosts: all
  roles:
    - role: gsa.datagov-deploy-mysql
```

### Dependencies

- PyMySQL


### Variables

**`mysql_app_name`** string

The name of your application which will be used as a default for the database name, user, and other configuration.


**`mysql_user_password`** string **required**

The password to set on the database user, used for your app to login to the
database.


**`mysql_user_name`** string (default: `{{ mysql_app_name }}`)

Explicitly set the database user name to create.


**`mysql_database_name`** string (default: `{{ mysql_app_name }}`)

The name of the database to create.


**`mysql_login_host`** string (default: `localhost`)

The remote host where the database will be created.


**`mysql_login_user`** string (default: `root`)

The master database user with superuser permissions to login as. This user is
used by the role to create and configure the database. It should **not** be your
app user.


**`mysql_login_password`** string **required**

The master password to use to login to the PostgreSQL host.





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
