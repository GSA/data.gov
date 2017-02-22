# [`manage-stack.sh`](./manage-stack.sh)

+ [Description](#description)
+ [Syntax](#syntax)
  - [Options](#options)
+ [Configuration](#configuration)
+ [Limitations](#limitations)

## <a name="description"></a>Description

`manage-stack.sh` provides the capability of managing a set of AWS resources,
which is referred to as a
[_Stack_](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-stack.html), using
[AWS Cloud Formation](https://aws.amazon.com/cloudformation/).
It allows for creating, updating, or deleting that set of AWS resources.

The script will complie an store the scripts used by a stack in a
designated S3 bucket.

The script can use Terraform variables file, in the
[HCL (`tfvars`)](https://www.terraform.io/intro/getting-started/variables.html)
or the [properties](https://en.wikipedia.org/wiki/.properties) files format,
as input file to generate CloudFormation Stack parameters.
It will discover files in the designated source directories.
Additionally, input files may be specified using the `--input` parameter,
using any of the following <a name="input_specifiers"></a>specifiers:

1. An _S3 URI_,
   e.g. `--input s3://my-bucket/path/to/input.tfvars`.
   This assumes that the user running the script has access rights to this
   S3 object (either the object is publicly accessible, or the used AWS IAM
   Role/AWS-CLI profile has been granted access).

2. A _HTTP/S URL_,
   e.g. `--input https://s3.amazonaws.com/my-bucket/path/to/input.tfvar`.
   This assume that the user running the script has access rights to this S3
   object (either the object is publicly accessible, or the used AWS IAM
   Role/AWS-CLI profile has been granted access).

_NOTE_ that while this is a bash/Linux script, on Windows can be run using
`git-bash`, or [MinGW](http://www.mingw.org/).


## <a name="syntax"></a>Syntax

```
manage-stack.sh OPTIONS STACK_NAME ENVIRONMENT_NAME
```

- __STACK_NAME__ is the name that you give your grouping of AWS resources
  that this "stack" manages.
- __ENVIRONMENT_NAME__ is the name of the environment for which you are
  managing this stack

_BUCKET&#95;NAME_, _STACK&#95;NAME_ and _ENVIRONMENT&#95;NAME_ are used to
define the S3 location where the CloudFormation script files are stored
using the following naming convention
```
s3://BUCKET_NAME/cloud-formation/SYSTEM_NAME/STACK_NAME/ENVIRONMENT_NAME
```
See also options `--bucket`.
SYSTEM_NAME is read from the configuration file, as
`stack.parameters.System` or else defaults to `datagov`.


### <a name="options"></a>OPTIONS

- __-a, --action__
  Valid values are `create`, `delete`, and `verify`.
    + `create` will create a stack, or update an existing stack if an
      AWS CloudFormation stack already exists.
    + `verify` will compile the stack and verify the script files.
      Note that this does not guarantee that running `create` will succeed,
      or that there are no errors in the script. Verifying local scripts
      ihas limitations.
    + `delete` will remove the AWS CloudFormation stack (if it exists)
  The default value is `create`.
- __-b BUCKET_NAME, --bucket BUCKET_NAME__
  The name of the bucket where teh CloduFormation scripts are maintained.
  By default this value is `datagov-provisioning`.
  Note that this bucket is location is `us-east-1`.
- __-br REGION, --bucket-region REGION__
 The region where the bucket reside, if the designated bucket is a region
 that differs from the region of the Stack (see `--region`)
 By default this value is the same as the --region parameter.
 Note that this bucket is location is `us-east-1`.
- __-c CONTEXT, --security-context CONTEXT__
  A parameter that can be passed to Stacks to be used to compile KeyPair
  names automatically. E.g. <SYSTEM_NAME>&95;<CONTEXT>&95;<RESOURCE_NAME>
  allowing you to adopt a standard naming scheme for EC2 key pairs.
  The default value is `ENVIRONMENT_NAME`,
  or if the environment name starts with `dev-` it is (just) `dev`.
- __-f FILE_NAME, --config-file FILE_NAME__
  Denotes the path to a YAML-based configuration file.
  The file may be specified as a "local" file, or as an S3 object.
  If no name is provided, the source directories are searched to find
  a file name `stack.yml`. The first one found is used,
  where the directories are searched (in order specified on the
  command-line).
  For format see [below](#configuration)
- __-i INPUT, --input INPUT__
  Reference to a valid Terraform variables file, either referencing a
  different stack, an S3 object, or a web-based (HTTP/S) file.
  See [above](#input_specifiers)
- __--no-cleanup__
  By default the script will delete the generated local target directory
  that is used to compile the stack. If this parameter is added, the target
  directory is not deleted.
- __-p PROFILE, --profile PROFILE__
  Denotes an aws profile to use when communicating with the AWS-API/CLI.
  This parameter is needed only when neither
  the script is not run on a server that has an IAM role assigned,
  nor the default profile should be used.
- __-r REGION, --region REGION__
  Denotes region to where to create the CloudFormation stack.
  as well as for script bucket (unless a separate region is specified using --bucket-region)
  Defaults to the value of environment variable AWS_REGION,
  or AWS_DEFAULT_REGION (in this order).
- __-q, --quiet__
  Suppresses all but error ouput messages.
- __-s DIR, --source-dir DIR__
  One or more directories where source files ( templates, polciy files,
  shell script, etc.) of the CloudFormation stack are located.
- __-t DIR, --target_dir DIR__
 Designates a specific directory as the directory, where Terraform is run
 and where files are generated (such as the state files and the output tfvars
 file), that subsequently are uploaded into the Terraform state bucket.
 The default target directory is _working directory>/target/_
- __-v, --verbose__
 Make the about more verbose. Repeated --verbose arguments make the output
 more verbose.
- __-w, --wait-for-completion MINUTES__
 When the script completes the Stack creation, update, or deletion
 has been initiated, but that action may not have completed yet.
 By specifiying this argument you can indicate how long (in minutes)
 the script should wait for the action to complete.
 The script will poll every 10 seconds to check if the action completed.
 if the wait times out the script returns an error code.


## <a name="configuration"></a>Configuration File

The configuration files are specified in YAML format. The file is expected to have the following structure:
```
stack:
  master_template: <master-template-name>
  templates:
    - <template-name-1>
    ..
    - <template-name-n>
  scripts:
     - <script-to-upload-1>
     ..
     - <script-to-upload-n>
   parameters:
      <parameter-1>: <value-1>
      ...
      <parameter-n>: <value-n> __ENVIRONMENT__
  input-mapping:
     <input-parameter-name-1>: <stack-parameter-name-1>
     ...
     <input-parameter-name-n>: <stack-parameter-name-n>
  ignored-input:
     - <ignored-input-parameter-1>
     - ...
     - <ignored-input-parameter-n>
  wait:
    conditions:
      <resource-logical-id-1>: aws-healthcheck
      ...
      <resource-logical-id-1>: aws-healthcheck
    delay: <delay-between-checks-in-seconds>
    max-iterations: <number-of-checks>
```
- __master_template__ The name of the master template, which serves as
  the CloudFormation script for the (main) stack.
  This file will be uploaded to the S3 provisioning bucket.
  The source directories are search for this file in the order they
  are provided.
  The file may also reside in a `templates` subdirectory
  of the source directories.
  Default: `main.json`
- __templates__ A list of file names that must be uploaded to
  the S3 provisioning bucket.
  The source directories are search for these files in the order they
  are provided.
  The files may also reside in a `templates` subdirectory
  of the source directories.
- __policy__ The name of the file that contains the stack policy
  definition.
  The files may also reside in a `policy` subdirectory
  of the source directories.
  Default: `default-stack-policy.json`
- __scripts__ A list of files that are to be uploaded to the S3
  provisioning bucket. These can subsequently be downloaded using
  the `userdata` specification of EC2 instances.
  The files may also reside in a `scripts` subdirectory
  of the source directories.
- __parameters__ A list of parameter names and values that will be
  added as CloudFormation stack parameters. The value may use an
  environment placeholder (`__VARIABLE_NAME__`) that will be replaced
  automatically by the value of the environment variable.
  By default the following variables are set and can be
  used as placeholders: STACK_NAME, BUCKET_NAME, ENVIRONMENT,
  AWS_PROFILE (when --profile is provided, or set explicitly
  and exported before calling the script),
  AWS_REGION (when --region is provided, or set explicitly
  and exported before calling the script),
  STACK_PATH (location where stack scripts are uploaded),
  MASTER_TEMPLATE, STACK_POLICY
  Note that these values are typically hard-coded values, unless
  a variable placeholder is used. Alternatively, a variables files
  may be provided via an `--input` argument.
- __input-mapping__ By default all properies are used to generate stack
  parameters. If the name of a parameter does not match, or the same
  parameter must be used for more than one stack input parameter, this
  defines mapping of name of one or more properties specified in an
  input file to another name that is used as a stack parameter.
  If no mapping is provided for a property name, the name is used verbatim.
- __ignored-input__ Defines a list of propery names in an input file that
  should not be used to generate stack parameters.
- __wait.conditions__ A list of ec2-instances named by logical-id, as
  specified in the CloudFormation template and the condition that must be
  met (currently only supports aws-healthcheck) before the script completes.
  the condition `aws-healthcheck` checks if both  instance health checks
  pass.
- __wait.delay__ Defaults to 10 seconds
- __wait.max-iterations__ Defaults to a calculated value based on the
  value of `wait.delay`that equates to a wait timeout after 2 hours.


## <a name="limitations"></a>Limitations

-  The current script only handles string variables, and not
   structured (array and map) variables, in a tfvars input file.
   This could be added at a later time.
