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
| Development *Environment* | <img src="https://img.shields.io/badge/status-Completed-brightgreen.svg" /> | 9/1/2016 |
| Staging *Environment*     | <img src="https://img.shields.io/badge/status-In%20Progress-yellow.svg" /> | 10/30/2016 |
| Production *Environment*  | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" /> | 11/30/2016 |
| System Security Plan | <img src="https://img.shields.io/badge/status-In%20Progress-yellow.svg" /> | 9/1/2016 |
| Authority to Operate kick-off meeting | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" /> | 11/1/2016 |
| Scanning and Penetration Testing | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" /> | 11/1/2016 |
| *Remediation of scanning/pen test findings* | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" /> | 11/1/2016 - 11/15/2016 |
| Authority to Operate Issued | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" /> | 11/30/2016 |
| Infrastructure Switch Over | <img src="https://img.shields.io/badge/status-On%20Track-blue.svg" /> | 12/1/2016 - 1/1/2016 |

# Requirements for Infrastructure and Software Provisioning
- [ ] Ansible > 1.10
- [ ] SSH access (via keypair) to remote instances
- [ ] [Static Inventory of Instances](http://docs.ansible.com/ansible/intro_inventory.html) OR using [Ansible AWS Cloud Module for a dynamic inventory](http://docs.ansible.com/ansible/intro_dynamic_inventory.html)

## Requirements for Infrastructure Provisioning (Dev/Test)
- [ ] Install Boto3 (AWS API SDK) Python library on ssh host
`sudo pip install boto3`
- [ ] Add a ansible-secret.txt
`nano ansible-secret.txt`
Copy/Paste

Set Shell Variable for Ansible Vault
`export ANSIBLE_VAULT_PASSWORD_FILE=~/ansible-secret.txt`

## Create Development Environment

**Create a Virtual Private Cloud (VPC):**
`ansible-playbook create_datagov_vpc.yml -e "vpc_name=datagov"`

**Delete VPC:**
`ansible-playbook delete_datagov_vpc.yml -e "vpc_name=datagov"`

**Create stack within VPC:**
`ansible-playbook create_catalog_stack.yml "vpc_name=datagov"`

**Delete stack within VPC:**
`ansible-playbook delete_catalog_# Requirements:

- boto3 (for infrastructure provisioning only): https://github.com/boto/boto3
- ansible-secret.txt: `export ANSIBLE_VAULT_PASSWORD_FILE=~/ansible-secret.txt`
- run all provisioning/app deployment commands from repo's `ansible` folder 
- for wordpress/dashboard/crm run the following command within the role's root folder before you provision anything: `ansible-galaxy install -r requirements.yml`
- {{ inventory }} can be:
  - inventories/staging/hosts
  - inventories/production/hosts
  - inventories/local/hosts

# Provision Infrastructure
## VPC:

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
## Wordpress:

**provision vm:** `ansible-playbook datagov-web.yml -i {{ inventory }} --skip-tags="deploy-rollback" --limit wordpress-web`
**deploy app:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="deploy" --limit wordpress-web`
**deploy rollback:** `ansible-playbook datagov-web.yml -i {{ inventory }} --tags="deploy-rollback" --limit wordpress-web`
## Dashboard

**provision vm:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --skip-tags="deploy-rollback" --limit dashboard-web`
**deploy app:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="deploy" --limit dashboard-web`
**deploy rollback:** `ansible-playbook dashboard-web.yml -i {{ inventory }} --tags="deploy-rollback" --limit dashboard-web`
## CRM

**provision vm:** `ansible-playbook crm-web.yml -i {{ inventory }} --skip-tags="deploy-rollback" --limit crm-web`
**deploy app:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="deploy" --limit crm-web`
**deploy rollback:** `ansible-playbook crm-web.yml -i {{ inventory }} --tags="deploy-rollback" --limit crm-web" --limit crm-web`
## Catalog:

**provision vm - web:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="frontend,ec2" --skip-tags="solr,db,cron" --limit catalog-web`

**provision vm - harvester:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="harvester,ec2" --skip-tags="apache,solr,db,saml2,redis" --limit catalog-harvester`

**provision vm - solr:** `ansible-playbook catalog.yml -i {{ inventory }} --tags="solr" --limit catalog-solr`
## Inventory

**provision vm - web:** `ansible-playbook inventory.yml -i {{ inventory }} --skip-tags="solr,db" --limit inventory-web`
**deploy app:** `ansible-playbook inventory.yml -i {{ inventory }} --tags="deploy" --skip-tags="solr,db" --limit inventory-web`
**provision vm - solr:** `ansible-playbook inventory.yml -i {{ inventory }} --tags="solr" --limit inventory-solr`
