
# <a id="terraform"></a>Terraform

In order to manage AWS resources Terraform is used. The stack concept of
CloudFormation is applied in this context. That is, a stack is represented
by one Terraform root module maintained in source code in a git repository.
This Terraform 'stack' may have (sub) modules, or may use external modules.

With Terraform you are responsible for managing persistence of stack state,
stack dependencies (sharing of information between stacks), because it is not
a service like CloudFormation, but rather a command-line tool (only).

A stack management script ([manage-stack.sh](./bin/README.md))
is used to manage the following stack aspects:

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
  1. _Output of another stack_ (reference by bucket (optional), stack, and
     environment name),
     e.g. `stack-ouput://datagov-provisioning/infrastructure/prod`
  2. _An S3 object URI_ e.g.
    `s3://datagov-provisioning/terraform/inftrastructure/master/infrastructure-output.tfvars`
  3. _A HTTP/S URL_,
     e.g. `https://s3-us-east-1.amazonaws.com/datagov-provisioning/terraform/instratructure/master/infratstructure-output.tfvars`
     (this exampele assumes that http access is enabled on the bucket,
      which can be an simple  way to grant read-only access).

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

## See also
	• https://www.terraform.io/docs/state/
	• https://www.terraform.io/docs/modules/usage.html
	• https://www.terraform.io/docs/configuration/variables.html#variable-files
	• https://www.terraform.io/docs/configuration/outputs.html
