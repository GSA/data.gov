[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy)

# datagov-deploy

This is the main repository for the Data.gov Platform. We use this repository to
[track our team's work](https://app.zenhub.com/workspaces/datagov-devsecops-579a2532d1d6ea9c3fcf5cfa/board)
and for our [Ansible](https://www.ansible.com) playbooks that deploy all the
[Data.gov site components](https://github.com/GSA/datagov-deploy/wiki/Site-components):

  - www.data.gov (WordPress)
  - catalog.data.gov (CKAN 2.3)
  - inventory.data.gov (CKAN 2.5)
  - labs.data.gov/crm (Open311 CRM)
  - labs.data.gov/dashboard (Project Open Data Dashboard)

Additionally, each host is configured with common Services:

  - Baseline OS Hardening
  - GSA IT Security Agents
  - TLS host certificates
  - Postfix email server
  - Filebeat (Logging)
  - New Relic (Infrastructure Monitoring)
  - Trendmicro (OSSEC-HIDS)
  - [and more...](https://github.com/GSA/datagov-deploy-common)


See our [Roadmap](docs/roadmap.md) for where we're taking Data.gov.


## Environments

Production and staging environments are deployed to FAS Cloud Services (FCS,
formerly BSP). Our sandbox environments are provisioned by
[datagov-infrastructure-live](https://github.com/gsa/datagov-infrastructure-live).

GSA VPN access is required to access production and staging.

Environment | Deployed from      | ISP | Jumpbox
----------- | -------------      | --- | ----
production  | `master` (manual)  | BSP | datagov-jump2p.prod-ocsit.bsp.gsa.gov
staging     | `release/*` (manual)  | BSP | datagov-jump2d.dev-ocsit.bsp.gsa.gov
bionic      | `develop` (manual) | AWS sandbox | jump.bionic.datagov.us
ci          | `develop` (manual) | AWS sandbox | jump.ci.datagov.us
local       | feature branches   | laptop  | localhost


## Usage

All deployments are done from the Jumpbox. They are already configured with
these requirements:

- [Python](https://www.python.org) 3.6 or [pyenv](https://github.com/pyenv/pyenv)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) key (ansible-secret.txt)
- [Pipenv](https://pipenv.org/)


### Running playbooks

Once you're SSH'd into the jumpbox, follow these steps for deploy.

1. Assume the `ubuntu` user and start a tmux session to prevent disconnects.

       $ sudo su -l ubuntu
       $ tmux attach
       
   Or if there are no existing tmux sessions, start a new one.
   
       $ tmux

1. Switch to the datagov-deploy directory.

       $ cd datagov-deploy

1. Check you are on the correct branch and up-to-date. The branch depends on the
   [environment](#environments) you're working with.

       $ git status
       $ git pull

1. Update python dependencies.

       $ pipenv sync

1. Update Ansible role dependencies.

       $ pipenv run make update-vendor-force

1. Run the playbook from the ansible directory.

       $ cd ansible
       $ pipenv run ansible-playbook site.yml --skip-tags filebeat
       
   _Note: we skip filebeat on deploys due to a version lock (https://github.com/GSA/datagov-deploy-common/issues/24)._


### Common plays

_These commands assume you've activated the virtualenv with `pipenv shell` or you can
prefix each command with `pipenv run` e.g. `pipenv run ansible`._

Deploy the entire Platform, including Applications, into a consistent state.

    $ ansible-playbook site.yml

If the playbooks failed to apply to a few hosts, you can address the failures
and then retry with the `--limit` parameter and the retry file.

    $ ansible-playbook site.yml --limit @site.retry

Or use `--limit` if you just want to focus on a single host or group.

    $ ansible-playbook site.yml --limit catalog-web

Deploy the Catalog application.

    $ ansible-playbook catalog.yml

Reboot any hosts, one by one, that require one e.g. after an apt-get
dist-upgrade.

    $ ansible-playbook actions/reboot.yml

Force a reboot even if no reboot is required. Use this if you just need to
reboot hosts for any reason.

    $ ansible-playbook actions/reboot.yml -e force_reboot=true --limit ${host}

Install the common Services.

    $ ansible-playbook common.yml

Upgrade OS packages as a one-off command on all hosts. _Note: If you find you're
doing one-off ansible commands often, then you should consider creating
a [situational
playbook](https://github.com/GSA/datagov-deploy/tree/develop/ansible/actions)._

    $ ansible -m apt -a 'update_cache=yes upgrade=dist' all

Reload the apache2 service for catalog.

    $ ansible -m service -a 'name=apache2 state=reload' catalog-web-v1

Run a one-off shell command. Just an example, don't ever run this ;)

    $ ansible -m shell -a "/usr/bin/killall dhclient && dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0" all

Tail the logs using `dsh`.

    $ dsh -g catalog-web-v1 -M -c tail -f /var/log/ckan/ckan.custom.log


### Application playbooks

Application playbooks deploy a single Application and its Services (e.g.
apache2). We document supported tags and common variables here, but you should
refer to the individual roles for the complete documentation.

_These commands assume you've activated the virtualenv with `pipenv shell` or you can
prefix each command with `pipenv run` e.g. `pipenv run ansible`._


#### Catalog

Provisions the Catalog app (catalog.data.gov).

    $ ansible-playbook catalog.yml

Provision only catalog-web.

    $ ansible-playbook catalog-web.yml

Provision only catalog-workers (harvesters).

    $ ansible-playbook catalog-worker.yml


##### Common variables

Variable | Description
-------- | -----------
`catalog_ckan_app_version` | Tag, branch, or commit of catalog-app to deploy


##### Supported tags

Tag      | Description
---      | -----------
pycsw    | Deploys only the PyCSW application
database | Configure the database with CKAN and PyCSW users


#### CRM

Deploy the Help Desk CRM application.

    $ ansible-playbook crm-web.yml --tags=provision,deploy

##### Common variables

Variable | Description
-------- | -----------
`project_git_version` | Tag, branch, or commit to deploy


#### Dashboard

Deploy the Project Open Data Dashboard.

    $ ansible-playbook dashboard-web.yml --tags=provision,deploy


##### Common variables

Variable | Description
-------- | -----------
`project_git_version` | Tag, branch, or commit to deploy


#### Inventory

Deploy inventory.data.gov.

    $ ansible-playbook inventory.yml


##### Common variables

Variable | Description
-------- | -----------
`inventory_ckan_app_version` | Tag, branch, or commit of ckan to deploy


#### PyCSW

PyCSW is our implementation of the Catalog Service for Web (CSW).

    $ ansible-playbook pycsw.yml

_Note: PyCSW is currently deployed as part of catalog.data.gov but probably
should be deployed and scaled independently._


##### Common variables

Variable | Description
-------- | -----------
`pycsw_app_version` | Tag, branch, or commit of pycsw to deploy


##### Supported tags

Tag      | Description
---      | -----------
database | Configure the database with PyCSW user


#### Solr

Deploy Solr.

    $ ansible-playbook solr.yml


#### WordPress

Deploys the www.data.gov (WordPress) application.

    $ ansible-playbook datagov-web.yml --tags=provision,deploy


##### Common variables

Variable | Description
-------- | -----------
`project_git_version` | Tag, branch, or commit to deploy


## Ansible inventory groups

We use several cross-cutting groups that allow us to deploy to different hosts
and set inventory variables based on different dimensions of our hosts.


### Stacks

These groups represent different major configurations of the base image.

- **v1** Ubuntu Trusty 14.04
- **v2** Ubuntu Bionic 18.04

Additionally, the application groups have a `-v1` suffix e.g. `catalog-web-v1`.
This helps us transition between stacks incrementally.


### Application processes

These groups represent different processes of applications, e.g. web and worker
processes which might be slightly different configurations of the same
application.

- **catalog-admin** web hosts for the catalog admin app (subset of **catalog-web**). This is CKAN
  with database write permissions.
- **catalog-web** web hosts for the catalog app. CKAN is configured read-only.
- **catalog-harvester** worker hosts for the catalog app.
- **crm-web** web hosts for the CRM app.
- **dashboard-web** web hosts for the Dashboard app.
- **inventory-web** web hosts for the inventory app.
- **pycsw-web** web hosts running the PyCSW application.
- **pycsw-worker** worker hosts running the PyCSW jobs.
- **wordpress-web** web hosts for the datagov/wordpress app.


### Service groups

- **jumpbox** host where Ansible playbooks are executed from.
- **solr** Solr hosts.
- **elasticsearch** Elasticsearch hosts in mgmt vpc only.
- **kibana** Kibana hosts in mgmt vpc only.
- **efk_nginx** EFK Nginx hosts in mgmt vpc only.

### Meta groups

- **web** meta group containing any hosts with a web server (e.g. apache2 or nginx).


## Development

Most development happens in the role repositories using
[molecule](https://molecule.readthedocs.io/en/stable/). There are still a few
roles here that you can develop on individually.


### Requirements

- [Docker Engine](https://docs.docker.com/engine/)
- [Python](https://www.python.org) 3.6 or [pyenv](https://github.com/pyenv/pyenv)
- [Pipenv](https://pipenv.org/)
- Ansible Vault key for editing secrets in inventory


### Setup

We use [pipenv](https://pipenv.org) to manage the Python virtualenv and
dependencies. Install the dependencies with make.

    $ make setup

Run the molecule and kitchen test suites locally. You probably don't want to do
this since it takes a long time and let [CI](./.circleci/config.yml) do it
instead. See below for more on how to work with individual test suites. Both
molecule and kitchen suites rely on docker for running tests in containerized
hosts.

    $ pipenv run make test

You can set the concurrency parameter with make's `-j` parameter.

    $ pipenv run make -j4 test


Lint your work.

    $ make lint


### Testing with molecule

[Molecule](https://molecule.readthedocs.io/en/latest/) is the preferred test
suite for testing roles. Playbooks can be tested by including them in the
molecule playbook.

Molecule is modular, so you must `cd` to the directory of the role you are
testing.

    $ cd roles/software/ckan/native-login
    $ molecule test

During development, you'll want to run only the converge playbook to avoid
creating/destroying the container every time.

    $ molecule converge

If you have multiple scenarios, you can specify them individually.

    $ molecule test -s <scenario>


### Testing with kitchen

_Note: we are [moving away](https://github.com/GSA/datagov-deploy/issues/581)
from test-kitchen in favor of molecule._

We use [Kitchen](https://kitchen.ci/) for testing playbooks.

Run a single suite.

    $ cd ansible
    $ bundle exec kitchen test catalog

Log into the instance to debug.

    $ cd ansible
    $ bundle exec kitchen login catalog

Re-run the playbook from a particular step.

    $ ANSIBLE_EXTRA_FLAGS='--start-at-task="software/ckan/apache : make sure postgresql packages are installed"' bundle exec kitchen converge catalog

Refer to [kitchen](https://kitchen.ci/) commands for more information.


### Editing Vault secrets

If you have the Ansible Vault key (`~/ansible-secret.txt`), you can review and
edit secrets with `ansible-vault`.

Review secrets in a vault.

    $ ansible-vault view [path-to-vault.yml]

Edit secrets in a vault.

    $ ansible-vault edit [path-to-vault.yml]

You can configure git to automatically decrypt Vault files for reviewing diffs.

    $ git config --global diff.ansible-vault.textconv "ansible-vault view"


## Troubleshooting

The CIS hardening benchmark sets a `027` umask, which means by default files are
not world-readble. This is often a source of problems, where a service cannot
read a configuration file.
