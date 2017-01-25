# [`manage-stack.sh`](./manage-stack.sh)

+ [Description](#description)
+ [Syntax](#syntax)
  - [Options](#options)
+ [Configuration](#configuration)
+ [Limitations](#limitations)

## <a name="description"></a>Description

`manage-stack.sh` provides the capability of managing a set of AWS resources,
which is referred to as a _stack_, using Terraform scripts. It allows for
creating, updating, or deleting that set of AWS resources.

The script will maintain the state of the stack (the resources) in a
designated S3 bucket. This is necessaryto allow for updating, as well as
passing output information to dependent stacks.

It automatically uses any valid Terraform variable file, so either an HCL
(`tfvars`) or `json` formatted file as input file. Additionally, input files
may be specified using the `--input` parameter, using any of the following
<a name="input_specifiers"></a>specifiers:



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

3. A __stack output URI__,
   e.g. --input `stack-output://my-bucket/a-stack/environment`.
   This allows propagation of variables from one to another stack. The output
   generated (with manage-stack.sh) for another stack will be downloaded. This
   allows propagating output from one stack to the next. Note that system-name
   can be empty, in which case the default "pilot" will be used". It assume the
   same bucket (as configured for the using stack) holds the generated output
   file. Generated output files will always be HCL formatted (tfvars) files.


_NOTE_ that while this is a bash/Linux script, on Windows this script works
when using `git-bash`

## <a name="syntax"></a>Syntax

```
manage-stack.sh OPTIONS STACK_NAME ENVIRONMENT_NAME
```

- __STACK_NAME__ is the name that you give your grouping of AWS resources
  that this "stack" manages.
- __ENVIRONMENT_NAME__ is the name of the environment for which you are
  managing this stack

_BUCKET&#95;NAME_, _STACK&#95;NAME_ and _ENVIRONMENT&#95;NAME_ are used to
define the S3 location where the Terraform state and generated output variables
file are stored using the following naming convention
```
s3://BUCKET_NAME/BUCKET_PATH/STACK_NAME/ENVIRONMENT_NAME
```
where _BUCKET&#95;PATH_ is `terraform` by default.
See also options `--bucket` and `--bucket-path`.


### <a name="options"></a>OPTIONS

- __-a, --action (required)__
  Valid values are `create` and `delete`. `create` will create a stack,
  or update an existing stack,if the state is found in the designated bucket.
  The default value is  `create`.

- __-b BUCKET_NAME, --bucket BUCKET_NAME__
  The name of the bucket where teh Terraform state is maintained.
  By default this value is `datagov-provisioning`.
  Note that this bucket is location is `us-east-1`.

- __-c PATH, --bucket-path PATH__
  Default path prefix for state within the designated bucket.
  The default value is `terraform`
- __-i INPUT, --input INPUT__
  Reference to a valid Terraform variables file, either referencing a
  different stack, an S3 object, or a web-based (HTTP/S) file.
  See [above](#input_specifiers)
- __-p PROFILE, --profile PROFILE__
  Denotes an aws profile to use when communicating with the AWS-API/CLI.
  If the script is run on a
- __-r REGION, --region REGION__
  Denotes region to use for the Terraform state bucket.
- __-q, --quiet__
  Suppresses all but error ouput messages.
- __-s DIR, --source-dir DIR__
  The directory where the Terraform stack's roo module is located.
  The default source directory is the _working directory_.
- __-t DIR, --target_dir DIR__
 Designates a specific directory as the directory, where Terraform is run
 and where files are generated (such as the state files and the output tfvars
 file), that subsequently are uploaded into the Terraform state bucket.
 The default target directory is
 _working directory>/target/<stack name>/<environment name>_
- __-v, --verbose__
 Make the about more verbose. Repeated --verbose arguments make the output
 more verbose.
- __-n, --no-wait__
 By default the script will check if any wait conditions for EC2 instances
 exist.
 If so, the script will wait until those conditions are met,
 or a predefned timeout period has been reached.


## <a name="configuration"></a>Configuration File

The source directory can contain a configuration file named `stack.yml`
in YAML format. In this configuration file you can define for EC2 instances
by resource name, to pass all health-checks before the script completes.
This assumes your Terraform script sets the following tags on the
EC2 instances in order to find the resource:

- System=datagov
- Stack=STACK_NAME
- Environment=ENVIRONMENT_NAME
- Resource=NAME_OF_YOUR_RESOURCE

The `stack.yml` file is expected to have the following structure:
```
stack:
  wait:
    conditions:
      <name-of-resource-1>: aws-healthcheck
      ...
      <name-of-resource-n>: aws-healthcheck
    delay: <delay-between-checks-in-seconds>
    max-iterations: <number-of-checks>
```
The values `delay` and `max-iterations` are optional, and will default to
15 seconds, resp. a calculated value that equates to a wait timeout after
2 hours.


## <a name="limitations"></a>Limitations

-  The current script only handles generation of string variables, not
   structured (array and map) variables. The Terraform output cli command
   does not generate valid HCL, so the script converts the output. This
   should be added at a later time.

- Ideally a dependency between stack could be defined, such that the
  manage-stack script can manage the relationship between stacks. This
  could be added as a command-line argument (e.g.
  `--depends-on stack-name/branch-name`).
  This should be added at a later time.
