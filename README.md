# Catalog Deploy

This main repository for Data.gov's stack deployment onto AWS Infrastructure. The responsitory is broken into the following roles all created/provisioned using [Ansible](http://docs.ansible.com/ansible/intro_installation.html) and :

Included in this Repository:
  - Infrastructure (*for dev environment)
    - Terraform + Rancher for [Dev/Test Environment](https://github.com/gsa/catalog-app)
    - Ansible (AWS) Cloud Module (Test/Staging Emulated Production Architecture)
  - Platform (*for Development Purpose Only*)
  - Host Operating System Hardening (CIS Benchmark for Ubuntu 14.04 LTS)
  - Software
    - Components
    - Configuration
  - Security
    - Components
    - Configuration
  - Monitoring
    - Components
    - Configuration

## Project Status

| Milestone | Status | Target Date |
| --- | --- | --- |
| Architecture | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 8/16/2016 |
| Development *Environment* | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 10/1/2016 |
| Staging *Environment*     | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 10/30/2016 |
| Production *Environment*  | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 12/15/2016 |
| System Security Plan | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> &  <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" />| 12/8/2016 (90 Day) & 12/8/2016 (1 Year ATO) |
| Authority to Operate kick-off meeting | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 12/8/2016 |
| Scanning and Penetration Testing | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 12/1/2016 |
| *Remediation of scanning/pen test findings* | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" />  | 12/5/2016 |
| Authority to Operate Issued 90-day | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" />  | 12/8/2016 |
| Infrastructure Switch Over | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" />| 12/29/2016 |
| Start of 1 year Authority to Operate | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" />  | 1/2/2017 |

# Requirements for Infrastructure and Software Provisioning
- Ansible > 1.10
- SSH access (via keypair) to remote instances
- boto3 (for infrastructure provisioning only): https://github.com/boto/boto3
- ansible-secret.txt: `export ANSIBLE_VAULT_PASSWORD_FILE=~/ansible-secret.txt`
- run all provisioning/app deployment commands from repo's `ansible` folder 
- for wordpress/dashboard/crm/monitoring/jekyll run the following command within the role's root folder before you provision anything: `ansible-galaxy install -r requirements.yml`
- {{ inventory }} can be:
  - inventories/staging/hosts
  - inventories/production/hosts
  - inventories/local/hosts

# Provision Infrastructure
*Terraform folder for latest - Ansible provisioning deprecated in favor*


## VPC **(Deprecated - See Terraform directory)**:

**create vpc:**
`ansible-playbook create_datagov_vpc.yml -e "vpc_name=datagov"`

**delete vpc:** 
`ansible-playbook delete_datagov_vpc.yml -e "vpc_name=datagov"`
## Catalog:

**create stack :**
`ansible-playbook create_catalog_stack.yml "vpc_name=datagov"`

**delete stack:**
`ansible-playbook delete_catalog_stack.yml "vpc_name=datagov"`

# Provision apps
cd /catalog-deploy/ansible and us -i "inventory/../hosts" flag to run playbooks w/ `ansible-playbook --help` or as` ansible all -a "cmd"` to run a one-off command on all hosts (only suggested for `-m ping` for query/stats/services all installation and configuration is done using playbooks)

## Wordpress:

**provision vm & deploy app:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="provision" --limit wordpress-web`

**deploy app:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="deploy"`

**deploy rollback:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="deploy-rollback"`

## Dashboard

**provision vm & deploy app:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="provision" --limit dashboard-web`

**deploy app:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="deploy"`

**deploy rollback:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="deploy-rollback"`

## CRM

**provision vm & deploy app:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="provision" --limit crm-web`

**deploy app:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="deploy"`

**deploy rollback:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="deploy-rollback"`

## Catalog:

**provision vm - web:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="frontend,ec2" --skip-tags="solr,db,cron" --limit catalog-web`

**provision vm - harvester:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="harvester,ec2" --skip-tags="apache,solr,db,saml2,redis" --limit catalog-harvester`

**provision vm - solr:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="solr,secops,trendmicro,misc" --limit solr`

## Inventory

**provision vm && deploy app:** `ansible-playbook inventory.yml -i {{ inventory }} --skip-tags="solr,db,deploy-rollback" --limit inventory-web`

**provision vm - solr:** `ansible-playbook inventory.yml -i {{ inventory }} --tags="solr,secops,trendmicro,misc" --limit solr`

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

