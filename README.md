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

Run a single suite.

    $ cd ansible
    $ bundle exec kitchen test catalog

Log into the instance to debug.

    $ cd ansible
    $ bundle exec kitchen login catalog

Re-run the playbook from a particular step.

    $ ANSIBLE_EXTRA_FLAGS='--start-at-task="software/ckan/apache : make sure postgresql packages are installed"' bundle exec kitchen converge catalog

Lint your work.

    $ make lint


Refer to [kitchen](https://kitchen.ci/) commands for more information.
