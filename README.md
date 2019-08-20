# Data.gov Deploy
[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy)

This main repository for Data.gov's stack deployment onto AWS Infrastructure. The repository is broken into the following roles all created/provisioned using [Ansible](http://docs.ansible.com/ansible/intro_installation.html):

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


## Project Status

See our [Roadmap](docs/roadmap.md).


## Provision Infrastructure
Moved to [datagov-infrastructure-live](https://github.com/gsa/datagov-infrastructure-live)

## Requirements for Software Provisioning
- Ansible > 1.10
- SSH access (via keypair) to remote instances
- ansible-secret.txt: `export ANSIBLE_VAULT_PASSWORD_FILE=~/ansible-secret.txt`
- run all provisioning/app deployment commands from repo's `ansible` folder
- to update `ansible/roles/vendor` roles run there: `ansible-galaxy install -r requirements.yml`


## Common plays

Update/deploy all data.gov assets.

    $ ansible-playbook site.yml

_Note: the above playbook is incomplete. There are a few playbooks that must be
run with specific parameters. For that we include them in `site.sh`:_

    $ ./site.sh {{ inventory }}

If the playbooks failed to apply to a few hosts, you can address the failures
and then retry with the `--limit` parameter and the retry file.

    $ ansible-playbook site.yml --limit @site.retry

Reboot any hosts requiring reboot after an update. _Note: this takes a while since we only reboot one host at a time._

    $ ansible-playbook actions/reboot.yml

Force reboot hosts even if no reboot is required. Use this if you just need to
reboot hosts for any reason.

    $ ansible-playbook actions/reboot.yml -e force_reboot=true

Install the trendmicro agent.

    $ ansible-playbook trendmicro.yml

Upgrade OS packages as a one-off command on all hosts.

    $ ansible -m apt -a 'update_cache=yes upgrade=dist' all

Reload the apache2 service for catalog.

    $ ansible-playbook -m service -a 'name=apache2 state=reload' catalog-web-v1

Run a one-off shell command.

    $ ansible -m shell -a "/usr/bin/killall dhclient && dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0" all

Tail the logs using `dsh`.

    $ dsh -g catalog-web-v1 -M -c tail -f /var/log/apache2/ckan.custom.log


## Provision apps

`cd ansible`

`ansible-playbook --help`

See example(s) below

### Wordpress:

**provision vm & deploy app:** `ansible-playbook datagov-web.yml --tags="provision" --limit wordpress-web`

**deploy app:** `ansible-playbook datagov-web.yml --tags="deploy" --limit wordpress-web`

**deploy rollback:** `ansible-playbook datagov-web.yml --tags="deploy-rollback" --limit wordpress-web`

- You can override branch to be deployed via `-e project_git_version=develop`

  ***e.g.*** `ansible-playbook datagov-web.yml --tags=deploy --limit wordpress-web -e project_git_version=develop`

### Dashboard

**provision vm & deploy app:** `ansible-playbook dashboard-web.yml --tags="provision" --limit dashboard-web`

**deploy app:** `ansible-playbook dashboard-web.yml --tags="deploy"`

**deploy rollback:** `ansible-playbook dashboard-web.yml --tags="deploy-rollback"`

### CRM

**provision vm & deploy app:** `ansible-playbook crm-web.yml --tags="provision" --limit crm-web`

**deploy app:** `ansible-playbook crm-web.yml --tags="deploy"`

**deploy rollback:** `ansible-playbook crm-web.yml --tags="deploy-rollback"`

### Catalog:

**provision vm - web:** `ansible-playbook catalog.yml --tags="frontend,ami-fix,bsp" --skip-tags="solr,db,cron" --limit catalog-web`

**provision vm - harvester:** `ansible-playbook catalog.yml --tags="harvester,ami-fix,bsp" --skip-tags="apache,solr,db,saml2" --limit catalog-harvester`

**provision vm - solr:** `ansible-playbook catalog.yml --tags="solr,ami-fix,bsp" --limit solr`

### Inventory

**provision vm && deploy app:** `ansible-playbook inventory.yml --skip-tags="solr,db,deploy-rollback" --limit inventory-web`

**provision vm - solr:** `ansible-playbook inventory.yml --tags="solr,ami-fix,bsp" --limit solr`

### ElasticSearch

**provision vm && deploy app:** `ansible-playbook elasticsearch.yml`

### Kibana

**provision vm && deploy app:** `ansible-playbook kibana.yml`

### EFK nginx

**provision vm && deploy app:** `ansible-playbook efk_nginx.yml`


## Troubleshooting:

The CIS hardening benchmark sets a `027` umask, which means by default files are
not world-readble. This is often a source of problems, where a service cannot
read a configuration file.


## Inventory

This section describes how the Ansible inventories are organized and variables
defined.

### Groups

**catalog-admin**

Web hosts for the catalog admin app (subset of catalog-web). This is CKAN
with a write configuration.


**catalog-web**

Web hosts for the catalog app. CKAN is configured read-only.


**catalog-harvester**

Worker hosts for the catalog app.


**crm-web**

Web hosts for the CRM app.


**dashboard-web**

Web hosts for the Dashboard app.


**inventory-web**

Web hosts for the inventory app.


**jumpbox**

Jumpbox host where Ansible playbooks are executed from.


**pycsw-web**

Web hosts running the PyCSW application.


**pycsw-worker**

Worker hosts running the PyCSW jobs.


**solr**

Solr hosts.


**wordpress-web**

Web hosts for the datagov/wordpress app.


**elasticsearch**

Elasticsearch hosts in mgmt vpc only.


**kibana**

Kibana hosts in mgmt vpc only.


**efk_nginx**

EFK hosts in mgmt vpc only.


**v1**

v1 hosts. These hosts run Ubuntu Trusty. Each group name will have a `-v1` suffix e.g.
`catalog-web-v1`.
This helps us transition between stacks.


**v2**

v2 hosts. These hosts run Ubuntu Bionic. Each group name will have a -v2 suffix e.g.
`catalog-web-v2`. This helps us transition between stacks.


**web**

Meta group containing any hosts with a web server (e.g. apache2 or nginx).


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

    $ molecule test -s <scenario>


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
