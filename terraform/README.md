# Terraform

[Terraform](https://www.terraform.io/) is an automation tool for managing
infrastructure as code. Resources are described in templates and then applied in
an automated fashion.

These terraform templates are meant to provide an easy way to provision
a testing environment that can be used to test the ansible playbooks.
Unfortunately, BSP does not support any automation in development and production
environments, so these templates are currently not used in those environments.

Currently, state is only stored locally with the intention of each developer
having their own sandbox instance. **Please destroy your sandbox once you are
done testing it** since there is no automated cleanup process.


## Setup

Export your AWS access key information.

```shell
export AWS_ACCESS_KEY_ID=<your-aws-access-key-id>
export AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
```

Everything is run from the `terraform` directory.

    $ cd terraform

Make a copy of `terraform.sample.tfvars` and edit it with your information.

    $ cp terraform.sample.tfvars terraform.tfvars
    $ $EDITOR terraform.tfvars

Initialize terraform.

    $ terraform init

Create a plan.

    $ make plan

Inspect the output. If the plan looks appropriate, apply it.

    $ make apply

This will output several variables that will be useful. For example, this shows
the IP address for your own personal jumpbox as well as database hostnames. Add
any additional output variables to `outputs.tf`.

```
Outputs:

db_catalog_master = adb-catalog-master20180831224245815800000001.czspvxktlmh6.us-west-1.rds.amazonaws.com
db_catalog_replicas = [
    adb-catalog-replica020180831230623447100000002.czspvxktlmh6.us-west-1.rds.amazonaws.com
]
db_pycsw_master = adb-catalog-pycsw-master20180831225340111000000002.czspvxktlmh6.us-west-1.rds.amazonaws.com
db_pycsw_replicas = [
    adb-catalog-pycsw-replica020180831230540945400000001.czspvxktlmh6.us-west-1.rds.amazonaws.com
]
jumpbox_ip = 13.56.207.197
```

You can then ssh into the jumpbox you just created. _TODO: use the jumpbox
playbook and turn this into an AMI._

    $ make jumpbox
    $ sudo apt-get install -y git python-pip python-virtualenv
    $ virtualenv venv && source venv/bin/activate
    $ pip install -U pip
    $ pip install ansible~=2.5.4
    $ git clone git@github.com:GSA/datagov-deploy.git

_TODO: Generate ansible inventory from terraform output._
