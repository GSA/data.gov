
# Infrastructure-as-Code Approach

+ [Introduction](#intro)
+ [Workflow](#workflow)
   - [Feature Development Workflow](#dev-workflow)
   - [Feature Implementation Workflow](#impl-workflow)
+ [Tools](#tools)
   - [Terraform](#terraform)
   - [Jenkins](#jenkins)

## <a id="intro"></a>Introduction

TBD



## <a id="workflow"></a>Workflow

### <a id="dev-workflow"></a>Feature Development Workflow

Overall development workflow is the "same" as any other development workflow
and assumes that uses short-lived feature branches. Note that a feature is
used here to indicate a relatively small individual change, not an aggregate
of multiple changes). This workflow is then applies to manage
infrastructure-as-code (IaC).

![xxx](./FeatureDevelopmentWorkflow.png)

|Step|Process Phase              |Description                                 |
|----|---------------------------|--------------------------------------------|
| 1  | Define Feature            |Provide a high-level specification of the change, e.g. in a GitHub issue to plan for implementing a change. "Change security groups and/or Network ACLs to allow communication with Active Directory server" is an example of such a change.|
| 2  | Pull Feature into Sprint  |In Scrum the feature is planned for the current sprint, meaning it is added to the sprint during sprint planning. Then a developer starts working on it during the sprint. In Kanban a developer just starts working on it.|
| 3  | Implement feature	       |A developer actively works in implementing the feature. Once complete it triggers the Jenkins pipeline execution. Note that depending on you set this up, the development work can be part of the Jenkins pipeline execution. See Implementation Workflow.|
| 4  | Execute Pipeline          |The Jenkins pipeline executes Build product (if necessary), deploying product/executing deployment script, (manually/automatically)  test deployed product, propagate through downstream environments. After/before each step there could be manual check-points where a person must approve the pipeline from  continuing. After/before each step there could be notification sent to designated parties.|
| 5  | Mark the feature as complete|Mark the feature is completed, e.g. close the GitHub issue, once it is moved to the production environment.|


### <a id="impl-workflow"></a>Feature Implementation Workflow

![xxx](./FeatureImplementationWorkflow.png)


|Step|Process Phase              |Description                                 |
|----|---------------------------|--------------------------------------------|
| 1  | Create Branch             |A developer starts with creating a new git branch in the applicable repository (or repositories). When using a Jenkins multi-branch pipeline (desirable) this would automatically detect the new branch and execute the branch. Or alternatively, the developer would have to enable Jenkins building the branch pipeline. If the pipeline is setup to deploy to downstream environments, need to ensure that feature branches only execute against an upstream environment.|
| 2	 | Code (and deploy)         |The developer clones the new repository, makes changes to the code, and deploys the code. E.g. changes are made in terraform scripts to update the NAT servers to use an AMI that has enhance networking, as well as to enable enhanced networking, to get better performance of internally generated outbound traffic. The developer runs the stack management script to update the terraform infrastructure stack, for the newly created branch. The Terraform stacks must create branch specific environments. This could be run locally, or be handled through Jenkins (which would then require git commits/pushes to the newly created branch).|
| 3	 | Test                      |The developer tests the deployed code. This could be manually, but ideally the developer creates automated tests that can be run repeatedly, as well as be built into the pipeline, using something like [serverspec](http://serverspec.org/) and/or [serverspec-aws-resources](https://github.com/stelligent/serverspec-aws-resources)|
| 4  |Create Pull Request (PR)   |Once the developer has completed testing, a PR is created, including a high-level description of the changes (for the reviewers).|
| 5  |Review Pull Request (PR)   |Reviewer(s) look at the PR ad determine if further changes are needed. If so assign back to the developer.|
| 6  |Merge branch               |Otherwise, merge (and delete the branch). This should kick-off the Jenkins pipeline for the branch which has been merged to.|




## <a id="tools"></a>Tools


### <a id="terraform"></a>Terraform

In order to manage AWS resources Terraform is used. The stack concept of
CloudFormation is applied in this context. That is, a stack is represented
by one Terraform root module maintained in source code in a git repository.
This Terraform 'stack' may have (sub) modules, or may use external modules.

With Terraform you are responsible for managing persistence of stack state,
stack dependencies (sharing of information between stacks), because it is not
a service like CloudFormation, but rather a command-line tool (only).

A stack management script is used to manage the following stack aspects:

- __Stack Creation/Update and Deletion__ - The management script can be used
  to create/update or destroy stacks. The script is intended to be a small
  building block of the development pipeline. It can be called from anywhere.
  Developer workstation, Jenkins, etc. It is also possible to intermingle
  where calls are made from, as the script relies on the S3 bucket for state,
  as long as the right parameters (indicating stack and branch name) are
  specified .
- __State Persistence__ - The script (automatically) manages state for a stack
  based on stack and branch name. This allows for development on multiple
  branches at the same time, without interference between stacks. The script
  can also destroy a specific stack, i.e. remove all (AWS) resources and remove
  the persisted state.
  A consistent naming convention of persisted state also enables the use of
  fine-grained AWS policies (if so desired).
- __Stack Input/Output__- Terraform allows for input and output. Input and
  output must be defined in the root module of the stack. The stack management
  script handles discovery of input variables defined with the stack in source
  code, as well as allows for designating externally defined variable files.
  These externally defined variables source files can be one of the following
  types:
  1. _Output of another stack_ (reference by stack and branch name), e.g. `stack-ouput://datagov/infrastructure/master`
  2. _An S3 object URI_ `s3://datagov-provisioing/terraform/instratructure/master/infratstructure-output.tfvars`
  3. _A HTTP/S URL_, e.g. `https://s3-us-east-1.amazonaws.com/datagov-provisioning/terraform/instratructure/master/infratstructure-output.tfvars`

  In order for output to be shared between stacks the scripts always generates
  a Terraform formatted variables file for the output variables defined in the
  stack's root module. Input variables should be used for anything that cannot
  be determined at development time, or may change after. Defaults can be
  defined in Terraform variables files in the source directory of root module
  (as they are automatically discovered by the script).

The following management tasks are planned to be added to the script:

- __Stack Dependency Management__ - Stacks are currently managed independently.
  This means an attempt can be made to delete a stack, even though another
  stack depends on it. Typically this fails for AWS resources, because the
  dependencies prevents Terraform from deleting them, but there is no guarantee.
  Ideally the persisted state includes information about dependencies to prevent
  problems with partially deleted stacks.

#### Practices To Apply

+  __Make the code modular__
   1. Avoids the use of long variable names to provide context
   2. Divide the script in multiple segments, which make easier to track and
      merge changes
   3. Reuse of provisioning code (avoid copy-paste and difficult maintenance)
+  __Ensure generated resources are identifiable__. It is easy to generate a
  lot of resources (for multiple stacks and code branches) that are not clearly
  labelled. This makes it harder to identify and manage those resources outside
  of terraform (if necessary)
   1. Use tags: System, Stack, Branch, Resource (ID); In AWS tagging enables
      the use Resource Groups that can make it easy to review and manage all
      resources from one central view
   2. Use naming scheme that combines some of the the above tags
      <System>_<Branch>_<Resource>
   3. The Terraform scripts must not hard-code to branch name at a minimum.
      Ideally the other values (except the resource id is shared/passed into
      main terraform script and passed down into modules.
+ __Enable/automate sharing of information across stacks__
   Avoids hard-coding of information which becomes cumbersome and 
   error-prone when using multiple stacks, and multiple branches per
   stack.
+ __Allow for a multi-layer provisioning approach__
   1. (Bootstrap) Manually create S3 bucket(s) used by provisioning tools
   2. Use terraform to provision Infrastructure (VPC, subnets, routing, NACLs,
      ELBs, EIPs, etc.
   3. Use terraform to provision resources (EC2 instances, ELBs, security
      groups, Elastic Cache, RDS instances, S3 buckets (not used by terraform,
      etc.)
   4. Use Ansible to provision OS and up on EC2 instances
   5. If using Docker, use Ansible to provision and create Docker images


#### See also
	• https://www.terraform.io/docs/state/
	• https://www.terraform.io/docs/modules/usage.html
	• https://www.terraform.io/docs/configuration/variables.html#variable-files
	• https://www.terraform.io/docs/configuration/outputs.html



### <a id="jenkins"></a>Jenkins (Pipeline)

TBD
