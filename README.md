[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy)

# data.gov main repository

_Note: most of the information in this repo refers to the "frozen" FCS environments of
data.gov. If you are looking for documentation for cloud.gov environments, see
the application repositories._

This is the main repository for the Data.gov Platform. We use this repository to
[track our team's work](https://app.zenhub.com/workspaces/datagov-devsecops-579a2532d1d6ea9c3fcf5cfa/board)
and for our [Ansible](https://www.ansible.com) playbooks that deploy the
[Data.gov site components](https://github.com/gsa/data.gov/wiki/Site-components) to FCS:

  - www.data.gov (WordPress)
  - catalog.data.gov (CKAN 2.8)
  - inventory.data.gov (CKAN 2.8)
  - labs.data.gov/dashboard (Project Open Data Dashboard)

Additionally, each host is configured with common Services:

  - Baseline OS Hardening
  - GSA IT Security Agents
  - TLS host certificates
  - Postfix email server
  - Filebeat (Logging)
  - New Relic (Infrastructure Monitoring)
  - Trendmicro (OSSEC-HIDS)
  - [and more...](https://github.com/gsa/datagov-deploy-common)

See our [Roadmap](docs/roadmap.md) for where we're taking Data.gov.


## Environments

Production and staging environments are deployed to FAS Cloud Services (FCS,
formerly BSP). Our sandbox environments are provisioned by
[GSA/datagov-infrastructure-live](https://github.com/gsa/datagov-infrastructure-live).

GSA [VPN access](https://github.com/gsa/data.gov/wiki/GSA-VPN) is required to access production and staging.

Environment | Deployment branch                      | ISP         | Jumpbox
----------- | -----------------                      | ---         | ----
mgmt        | `master`         | BSP         | datagovjump1m.mgmt-ocsit.bsp.gsa.gov
production  | `master`         | BSP         | datagov-jump2p.prod-ocsit.bsp.gsa.gov
staging     | `master`         | BSP         | datagov-jump2d.dev-ocsit.bsp.gsa.gov
sandbox     | `develop`        | AWS sandbox | jump.sandbox.datagov.us
local       | feature branches | laptop      | localhost


### Applications

FCS environments are considered "frozen" and only accepting security updates and
critical bug fixes. Applications are frozen on the `fcs` branch.


## Usage

All deployments are done from the Jumpbox. They are already configured with
these requirements:

- [pyenv](https://github.com/pyenv/pyenv) (recommended) or [Python](https://www.python.org) 3.6
- [Pipenv](https://pipenv.readthedocs.io/en/latest/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)


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
   [environment](#environments) you're working with. When doing a release, you
   should be on `release/YYYYMMDD`

       $ git status
       $ git pull --ff-only

1. Update python dependencies.

       $ pipenv sync

1. Update Ansible role dependencies.

       $ pipenv run make vendor

1. Run the playbook from the ansible directory.

       $ cd ansible
       $ pipenv run ansible-playbook site.yml

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

Deploy the static catalog application.

    $ ansible-playbook catalog.yml

Reboot any hosts, one by one, that require one e.g. after an apt-get
dist-upgrade.

    $ ansible-playbook actions/reboot.yml

Force a reboot even if no reboot is required. Use this if you just need to
reboot hosts for any reason.

    $ ansible-playbook actions/reboot.yml -e '{"force_reboot": true}' --limit ${host}

_Note: for Ansible to parse boolean values in
[`--extra-vars`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#passing-variables-on-the-command-line)
we use the JSON syntax in the above example._

Install the common Services.

    $ ansible-playbook common.yml

Upgrade OS packages as a one-off command on all hosts. _Note: If you find you're
doing one-off ansible commands often, then you should consider creating
a [situational
playbook](https://github.com/gsa/data.gov/tree/master/ansible/actions)._

    $ ansible -m apt -a 'update_cache=yes upgrade=dist' all

Reload the apache2 service for catalog.

    $ ansible -m service -a 'name=apache2 state=reload' catalog-web-v1

Run a one-off shell command. Just an example, don't ever run this ;)

    $ ansible -m shell -a "/usr/bin/killall dhclient && dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0" all

Tail the logs using `dsh`.

    $ dsh -g catalog-web-v1 -M -c tail -f /var/log/ckan/ckan.custom.log

Run a DB-SOLR sync for a dataset on catalog.

    $ ansible-playbook actions/catalog-db-solr-sync.yml --extra-vars "db_solr_sync_package_name=insert-package-name-here"


#### Supported tags

These tags are supported by the site.yml platform-wide playbook.

Tag       | Description
---       | -----------
catalog   | Catalog application within site.yml playbook
common    | Common plays within site.yml playbook
dashboard | Dashboard application within site.yml playbook
inventory | Inventory application within site.yml playbook
jumpbox   | Jumpbox plays within site.yml playbook
redis     | Redis plays within site.yml playbook
smoke     | Smoke/sanity tests
solr      | Solr plays within site.yml playbook
wordpress | WordPress application within site.yml playbook


### Application playbooks

Application playbooks deploy a single Application and its Services (e.g.
apache2). We document supported tags and common variables here, but you should
refer to the individual roles for the complete documentation. Note: deploying from the `master` branch will deploy a frozen version of each application via its `fcs` branch.

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

Tag       | Description
---       | -----------
smoke     | Smoke/sanity tests


#### Dashboard

Deploy the Project Open Data Dashboard.

    $ ansible-playbook dashboard-web.yml


##### Common variables

Variable | Description
-------- | -----------
`project_git_version` | Tag, branch, or commit to deploy


##### Supported tags

Tag       | Description
---       | -----------
smoke     | Smoke/sanity tests


#### Inventory

Deploy inventory.data.gov.

    $ ansible-playbook inventory.yml


##### Common variables

Variable | Description
-------- | -----------
`inventory_ckan_app_version` | Tag, branch, or commit of ckan to deploy


##### Supported tags

Tag       | Description
---       | -----------
smoke     | Smoke/sanity tests


#### Solr

Deploy Solr.

    $ ansible-playbook solr.yml


#### WordPress

Deploys the www.data.gov (WordPress) application.

    $ ansible-playbook datagov-web.yml


##### Common variables

Variable | Description
-------- | -----------
`project_git_version` | Tag, branch, or commit to deploy

Note: On the `master` branch, this variable should be set to `fcs`.


##### Supported tags

Tag       | Description
---       | -----------
smoke     | Smoke/sanity tests


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
- **dashboard-web** web hosts for the Dashboard app.
- **inventory-web** web hosts for the inventory app.
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

- [GNU Make](https://www.gnu.org/software/make/)
- [Docker Engine](https://docs.docker.com/engine/)
- [pyenv](https://github.com/pyenv/pyenv) (recommended) or [Python](https://www.python.org) 3.6
- [Pipenv](https://pipenv.readthedocs.io/en/latest/)
- [Vagrant](https://www.vagrantup.com/)
- [Ansible Vault key](https://docs.google.com/document/d/1detdsnIuwmqz6asrIfUWrmxCr56MGschY1yV0UeC_24/edit) for editing secrets in inventory


### Setup

We use [pipenv](https://pipenv.readthedocs.io/en/latest/) to manage the Python virtualenv and
dependencies. Install the dependencies with make.

    $ make setup

Install third-party Ansible roles.

    $ pipenv run make vendor

Any commands mentioned within this README should be run within the virtualenv.
You can activate the virtual with `pipenv shell` or you can run one-off commands
with `pipenv run <command>`.


### Tests

Run the molecule test suites locally. You probably don't want to do this since
it takes a long time and let [CI](./.circleci/config.yml) do it instead. See
below for more on how to work with individual test suites. Molecule tests rely
on docker for running tests in containerized hosts.

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

If you created a new scenario, be sure to add it to the appropriate variable in the [Makefile](./Makefile)


### Manual testing with Vagrant

_This is a work in progress. The Vagrant setup does not include the mysql
or postgres databases. The local Ansible inventory is also incomplete._

Where possible, you should use Docker and Molecule for developing and testing
your roles. There are some scenarios that you might want to manually test in
a virtual machine with Vagrant. For example, some tasks are captured in
a playbook instead of a role and playbooks are not tested with Molecule.

Initialize the vagrant environment.

    $ vagrant up

Test that you can connect to the vagrant instance with Ansible.

    $ ansible -i inventories/local -m ping all

Connect to the VM for debugging.

    $ vagrant ssh

Run the wordpress playbooks locally.

    $ ansible-playbook -i inventories/local common.yml datagov-web.yml

The local VM is considered to be in _all_ Ansible groups, so running the
`site.yml` playbook will apply every app and role to the VM, likely failing in
unexpected ways. For this reason, you should avoid running the `site.yml`
playbook and instead run `common.yml` with the application playbook.

Clean up the VM after your test.

    $ vagrant destroy


### Ansible Vault

Inventory secrets are stored encrypted within the git repository using [Ansible
Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). In order
to decrypt them for editing or review, you'll need [the Ansible Vault password](https://docs.google.com/document/d/1detdsnIuwmqz6asrIfUWrmxCr56MGschY1yV0UeC_24/edit).


#### Setup the vault password(s)

On invocations, you'll be prompted for the vault password. You should add the
password to a file and configure Ansible so that it reads the password from
file. In order to use `git log` to review vault history, you'll probably want
previous passwords as well. First, create a directory for the passwords.

    $ mkdir -m 0700 .secrets

Create a file (e.g. `.secrets/ansible-secret-v2.txt`) containing only a single
[Ansible Vault password](https://docs.google.com/document/d/1detdsnIuwmqz6asrIfUWrmxCr56MGschY1yV0UeC_24/edit).
You can add additional passwords if you wish, one password per file.
Then, set [`ANSIBLE_VAULT_IDENTITY_LIST`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-vault-identity-list)
to the list of password file paths (comma separated).

    $ echo ANSIBLE_VAULT_IDENTITY_LIST=$(find $(pwd)/.secrets -type f | sort -r | paste -s -d, -) > .env

Your .env should look like:

    ANSIBLE_VAULT_IDENTITY_LIST="/home/gsa/projects/datagov/datagov-deploy/.secrets/ansible-secret-v2.txt,/home/gsa/projects/datagov/datagov-deploy/.secrets/ansible-secret-v1.txt"

`pipenv` will load this `.env` file automatically if included at the root of
the project.

On jumpbox hosts, the vault password file should be installed to
`/etc/datagov/ansible-secret.txt` (group readable by operators). This is
a manual step for initial jumpbox provisioning. Ubuntu may need to be added
to the `operators` group.


#### Editing Vault secrets

If you have the Ansible Vault password (ask a team member), you can review and
edit secrets with `ansible-vault`.

Review secrets in a vault.

    $ ansible-vault view [path-to-vault.yml]

Edit secrets in a vault.

    $ ansible-vault edit [path-to-vault.yml]

You can configure git to automatically decrypt Vault files for reviewing diffs.

    $ git config --global diff.ansible-vault.textconv "ansible-vault view"


## Deployment

Because of GSA firewalls, we split our continuous integration and delivery into
two roles. CircleCI handles continuous integration and Jenkins handles
deployment within the GSA firewall.

On any commit, CircleCI runs the automated test suites and if successful, hands
off deployment to Jenkins.

Workflow   | Environments              | URL
--------   | ------------              | ---
production | staging, mgmt, production | https://ci-datagov.mgmt-ocsit.bsp.gsa.gov
sandbox    | sandbox                   | https://ci.sandbox.datagov.us


### Jenkins configuration

Using the
[configuration-as-code](https://plugins.jenkins.io/configuration-as-code/)
plugin, we are able to define the Jenkins configuration and its job
configuration in [code](./ansible/templates/jenkins_config.yml.j2).
After running the `jenkins.yml` playbook, there are a few manual steps that need
to be done.

1. Log into the new instance
1. Configure credentials
1. Add an API token for the admin user and update `jenkins_admin_password` with
   this token.
1. (sandbox only) Add a CI bot user and API token


#### Configure credentials

Add [credentials](https://ci-datagov.mgmt-ocsit.bsp.gsa.gov/credentials/) to manage secrets.

| Id                   | Type | Description |
| --                   | ---- | ----------- |
| ansible-vault-secret | file | File containing the password to the Ansible vault (ansible-secret-v2.txt). |
| datagov-sandbox      | file | [Root SSH private key](https://drive.google.com/drive/folders/10-hk-IqA0jQAW6727pKmW46EF-nHiNLr) file for the environment. |
| datagov-prod-ssh     | file | [Root SSH private key](https://drive.google.com/drive/folders/10-hk-IqA0jQAW6727pKmW46EF-nHiNLr) file for the environment. |
| github-datagov-bot   | text | Personal [access token](https://github.com/settings/tokens) from the datagov-bot GitHub user. |

_Note: evaluate if we want to move the credential creation to
configuration-as-code configuraiton._


#### CI user

With SAML authentication enabled, you can no longer create user/service accounts
through the UI. Instead, use the [script
console](https://ci-datagov.mgmt-ocsit.bsp.gsa.gov/script) to run the script below. Set
a random password. The return value is the API token. Save this for later as you won't have
another chance.

The CI user should be assigned to the `build-manager` role. This is already
configured in our configuration-as-code.

```groovy
// fill these out script parameters
def userName = 'ci'
def userPassword = // pwgen -s 64 1
def tokenName = 'circleci'

import hudson.model.*
import hudson.security.*
import jenkins.model.*
import jenkins.security.*
import jenkins.security.apitoken.*

// create the user
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(userName, userPassword)
instance.setSecurityRealm(hudsonRealm)
instance.save()

// create an API token for the user
def user = User.get(userName, false)
def apiTokenProperty = user.getProperty(ApiTokenProperty.class)
def result = apiTokenProperty.tokenStore.generateNewToken(tokenName)
user.save()

return result.plainValue
```


### CircleCI Setup

Add the following environment variables to CI configuration. These are required
for the `bin/jenkins_build` script. Secret variables should be entered in the
[UI configuration only](https://circleci.com/gh/GSA/datagov-deploy/edit#env-vars).

Variable | Description | Secret
-------- | ----------- | ------
`JENKINS_USER` | The Jenkins user with access to the API. | Y
`JENKINS_API_TOKEN` | The API token for the Jenkins user. | Y
`JENKINS_JOB_TOKEN` | The job token specified in the job configuration (see `jenkins_job_authentication_token`). | Y
`JENKINS_URL` | The URL to the Jenkins instance. | N

In the CI job configuration (`.circleci/config.yml`), run the `bin/jenkins_build
<job-name>` script.


## Troubleshooting

The CIS hardening benchmark sets a `027` umask, which means by default files are
not world-readble. This is often a source of problems, where a service cannot
read a configuration file.
