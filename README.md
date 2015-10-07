Catalog Deploy
===============================

**CKAN Version:** >= 2.3

...work in progress...

This ansible script will install ckanext-geodatagov with CKAN core >= 2.3 on Ubuntu LTS 14.04. 

####Virtualization requirements:
**Virtual Box:** `https://www.virtualbox.org/manual/ch02.html`

**Vagrant** 
- vagrant: `https://docs.vagrantup.com/v2/installation/`
- vagrant-hostmanager: `https://github.com/smdahlen/vagrant-hostmanager`

####VM Provisioning Requirements
**Ansible:**
`http://docs.ansible.com/ansible/intro_installation.html`

####AWS Requirements (optional)
**AWS CLI**: `http://docs.aws.amazon.com/cli/latest/userguide/installing.html`

####CloudFormation:
- Run the following command to create the AWS EC2 Stack (ec2 instance + security group + elastic ip)
`aws cloudformation create-stack --stack-name catalog-deploy-stack --template-body file://cloudformations/webserver.json`

Note: you might need to modify `cloudformations/webserver.json` to suit your needs.
