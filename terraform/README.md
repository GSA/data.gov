# Terraform for Data.gov
## What is Terraform?
[Terraform](https://www.terraform.io/intro/) is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

For Data.gov it will be used for creating the Amazon VPC, Subnets, Security Groups, NAT Gateways, Elastic Load Balancers, JumpHost, and the first Rancher server.

Long term goals are to automate Rancher HA, and adding new Rancher Nodes.

## Terraform Usage
copy Variable .template files to *name*.tf. This can be accomplished easily from the command-line by running:

__Mac/Linux:__ `for file in $(ls *template) ; do tf=$(basename $file .template) ; cp $file $tf ; done`

__Windows:__ `forfiles /M *.template /C "cmd -c copy @file @fname"`

Also on each, simply rename _terraform.tfvars.template_ to _terraform.tfvars_


Look at each of the Variable files and either verify the default values, or fill in the needed information.
Each variable file explination is listed below:
### variables.tf
* __environment:__ Select which environment this will be built for e.g. dev, test, production.  This will be used in naming conventions as well as AWS Tags
* __rancher_amis:__ The current list of the latest RancherOS AMIs.  (Currently not being used)
* __ubuntu_amis:__ The current list of the latest Ubuntu AMIs.
* __key_name:__ AWS KeyPair name
* __rancher_tag:__ Which version of Rancher to install.  Defaults to _latest_ however can be overriden to test RC releases, or pin to an older version.
* __domain:__ base domain used in Route53 to associate with the ELB (example.com)
* __zone_id:__ The Route53 ZoneID of the domain to associate with the ELB.

### vpc-variables.tf
* __aws_profile:__ Define which AWS profile to use as defined [here](https://www.terraform.io/docs/providers/aws/index.html) and defaults to using the `~/.aws/credentials` if you have configured the AWS CLI.
* __region:__ Which AWS region to put everything in (e.g. us-east-1)
* __vpc_cidr:__ Parent CIDR Block for the entire VPC. (Default: `10.0.0.0/24`)
* __subnet_cidrs:__ What CIDR blocks to use to split up the VPC
* __vpc_azs:__ Which Availability Zones to use.  Since every account has access to different AZ's it is best to check for your needs.

### sg-variables.tf
This is to house any variables associated with Security Groups. Right now it is only used to define two variables for CIDRS which will be allowed access to the setup.  The values should be put into __terraform.tfvars__

### rds-variables.tf
* __rds_size:__ Instance size for the RDS Instance (Default: db.t2.medium)
* __rds_disk_size:__ Amount of disk space to allocate for RDS in GB.(Default: 100GB)
* __rds_user:__ Admin user for RDS
* __rds_pass:__ Admin password for RDS


## Running Terraform

Once all of the vairables are set, run `terraform plan` and verify it all runs properly.
When the plan has successfully run, then run `terraform apply`
Once this is completed your environment should be completely setup.  It will send you outputs as to your RDS endpoint, and jumphost IP, and rancher ELB.

## Enable the ProxyProtocol on the new ELB
Once you have your ELB, you must enable the Proxy Protocol as detailed in the [AWS Documentation](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/enable-proxy-protocol.html#enable-proxy-protocol-cli) for the port 8080 instance backend.
In short it will look like this:

`aws elb create-load-balancer-policy --profile AWS_PROFILE --load-balancer-name ELB_NAME --policy-name rancher-proxy-protocol --policy-type-name PROXY_PROFILE_NAME ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true`

`aws elb set-load-balancer-policies-for-backend-server --profile AWS_PROFILE --load-balancer-name ELB_NAME --instance-port 8080 --policy-names PROXY_PROFILE_NAME`

Verify with:

`aws elb describe-load-balancers --profile AWS_PROFILE --load-balancer-name ELB_NAME --output json`

You should see this:

```json
"BackendServerDescriptions": [
    {
        "InstancePort": 8080,
        "PolicyNames": [
            "PROXY_PROFILE_NAME"
        ]
    }
],
```


## What is Rancher?
[Rancher](http://docs.rancher.com/rancher/) is an open source software platform that implements a purpose-built infrastructure for running containers in production.

The long term goal is to have this section do more with managing the Rancher Platform, however for now it is semi-manual for creating more servers and adding agents.

All of the Rancher data is kept in the RDS instance built by Terraform, which will ensure data persistance if the master ever goes down, or needs to be re-built, upgraded, etc.
