# Data.gov Deploy
[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy)

This main repository for Data.gov's stack deployment onto AWS Infrastructure. The responsitory is broken into the following roles all created/provisioned using [Ansible](http://docs.ansible.com/ansible/intro_installation.html):

Included in this Repository:
  - Software
    - Data.gov (Wordpress)
    - Catalog.data.gov (CKAN 2.3)
    - Inventory.data.gov (CKAN 2.5)
    - Labs.data.gov/CRM (Open311 CRM)
    - Labs.data.gov/Dashboard (Project Open Data Dashboard)
  - Security
    - Baseline OS Hardening
    - GSA IT Security Agents
    - Fluentd (Logging)
    - New Relic (Infrastructure Monitoring)
    - New Relic (Application Performance Monitoring)
    - Trendmicro (OSSEC-HIDS)
    - OSQuery (TBD)


## Project Status

See our [Roadmap](docs/roadmap.md).


# Provision Infrastructure
Moved to [datagov-infrastructure](https://github.com/gsa/datagov-infrastructure)

# Requirements for Software Provisioning
- Ansible > 1.10
- SSH access (via keypair) to remote instances
- ansible-secret.txt: `export ANSIBLE_VAULT_PASSWORD_FILE=~/ansible-secret.txt`
- run all provisioning/app deployment commands from repo's `ansible` folder
- to update `ansible/roles/vendor` roles run there: `ansible-galaxy install -r requirements.yml`
- `{{ inventory }}` can be:
  - inventories/staging/hosts
  - inventories/production/hosts
  - inventories/local/hosts

# Provision apps

`cd ansible`

`ansible-playbook --help`

See example(s) below

## Wordpress:

**provision vm & deploy app:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="provision" --limit wordpress-web`

**deploy app:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="deploy" --limit wordpress-web`

**deploy rollback:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="deploy-rollback" --limit wordpress-web`

- You can override branch to be deployed via `-e project_git_version=develop`

  ***e.g.*** `ansible-playbook datagov-web.yml -i inventories/staging/hosts --tags=deploy --limit wordpress-web -e project_git_version=develop`

## Dashboard

**provision vm & deploy app:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="provision" --limit dashboard-web`

**deploy app:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="deploy"`

**deploy rollback:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="deploy-rollback"`

## CRM

**provision vm & deploy app:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="provision" --limit crm-web`

**deploy app:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="deploy"`

**deploy rollback:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="deploy-rollback"`

## Catalog:

**provision vm - web:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="frontend,ami-fix,bsp" --skip-tags="solr,db,cron" --limit catalog-web`

**provision vm - harvester:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="harvester,ami-fix,bsp" --skip-tags="apache,solr,db,saml2" --limit catalog-harvester`

**provision vm - solr:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="solr,ami-fix,bsp" --limit solr`

## Inventory

**provision vm && deploy app:** `ansible-playbook inventory.yml -i {{ inventory }} --skip-tags="solr,db,deploy-rollback" --limit inventory-web`

**provision vm - solr:** `ansible-playbook inventory.yml -i {{ inventory }} --tags="solr,ami-fix,bsp" --limit solr`

## Jekyll

**provision vm && deploy app:** `ansible-playbook jekyll.yml -i {{ inventory }} --limit jekyll-web`

## ElasticSearch

**provision vm && deploy app:** `ansible-playbook elasticsearch.yml -i {{ inventory }}`

## Kibana

**provision vm && deploy app:** `ansible-playbook kibana.yml -i {{ inventory }}`

## EFK nginx

**provision vm && deploy app:** `ansible-playbook efk_nginx.yml -i {{ inventory }}`

## Common:
**install the trendmicro agent:** `ansible-playbook trendmicro.yml -i {{ inventory }}`

**Add SecOps user:** `ansible-playbook secops.yml -i {{ inventory }}`

## Upgrade ubuntu VMs:
`ansible all -m shell -a "apt-get update && apt-get dist-upgrade" --sudo`

`ansible all -m shell -a "service tomcat6 restart" --sudo`

`ansible all -m shell -a "service ntp restart" --sudo`

`ansible all -m shell -a "/usr/bin/killall dhclient && dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0" --sudo`

## Troubleshooting:
**dpkg errors**:

`sed -i '/postdrop/d' /var/lib/dpkg/statoverride`

`sed -i '/ssl-cert/d' /var/lib/dpkg/statoverride`

**ntpd issues**: `apt-get remove ntp && apt-get purge ntp && apt-get autoclean && apt-get autoremove`

**Unable to resolve host IP**: `echo 127.0.0.1 $(hostname) >> /etc/hosts`

## Development

Install the dependencies (from a python virtualenv).

    $ make setup

Run the playbooks locally.

    $ make test

You can set the concurrency parameter with make's `-j` parameter.

    $ make -j4 test

This runs all the suites, both molecule and kitchen tests. See below for more on
how to work with individual suites. Both suites rely on docker for running tests
within containers.

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

    $ moelcule test -s <scenario>


### Testing with kitchen

We use [Kitchen](https://kitchen.ci/) for testing playbooks, although we are
moving suites to molecule.

Run a single suite.

    $ cd ansible
    $ bundle exec kitchen test catalog

Log into the instance to debug.

    $ cd ansible
    $ bundle exec kitchen login catalog

Re-run the playbook from a particular step.

    $ ANSIBLE_EXTRA_FLAGS='--start-at-task="software/ckan/apache : make sure postgresql packages are installed"' bundle exec kitchen converge catalog

Refer to [kitchen](https://kitchen.ci/) commands for more information.


## Packer

Images built from packer are used for testing only. BSP currently does not allow
custom images.

In order to build images with packer, you'll need to set your AWS access key as
environment variables.

    $ export AWS_ACCESS_KEY_ID=<your-access-key-id>
    $ export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
    $ packer build packer/jumpbox.json

_Note: there is no default VPC so you must specify a subnet_id in which to
create the instance._

    $ packer build -var subnet_id=<subnet-id> packer/jumpbox.json

### Variables

Variable | Default | Description
-------- | ------- | -----------
`ami_name` | _varies_ | Use an alternate name for the image.
`region` | use-east-1 | Create the image for an alternate AWS region.
`env`    | test    | Create the image for an alternative environment.
`subnet_id` | _varies_ | Build the image with the specified subnet.
