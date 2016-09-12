# Catalog Deploy
**...work in progress...**

This main repository for Data.gov's stack deployment onto AWS Infrastructure. The responsitory is broken into the following roles all created/provisioned using [Ansible](http://docs.ansible.com/ansible/intro_installation.html) and :

- Ansible
  - Infrastructure (*for development environment)
  - Platform (*for development environment)
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

## Requirements
- [ ] Ansible > 1.10
- [ ] SSH access (via keypair) to remote instances
- [ ] [Static Inventory of Instances](http://docs.ansible.com/ansible/intro_inventory.html) OR using [Ansible AWS Cloud Module for a dynamic inventory](http://docs.ansible.com/ansible/intro_dynamic_inventory.html)

**To Create a Development Environment in AWS**
- [ ] sudo pip install boto3
## How To

#### Deploy a Development Environent in AWS

1. Create a Virtual Private Cloud (VPC)
