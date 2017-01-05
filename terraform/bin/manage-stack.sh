#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $0)
WORKING_DIR=$(pwd)

# =============================================================================
#  OUTPUT functions
# =============================================================================

VERBOSE_QUIET="0"
VERBOSE_OUTPUT="1"
VERBOSE_SOMEWHAT="2"
VERBOSE_EXTRA="3"
VERBOSE_DEBUG="4"
VERBOSE_TRACE="5"
VERBOSE="${VERBOSE_OUTPUT}"

#------------------------------------------------------------------------------
# Print an error message consiting of the concatenation of all arguments
#------------------------------------------------------------------------------
function error {
    local first_arg=$(echo "$1" | awk '{gsub(/[[:blank:]]/, ""); print;}')
    if [ "${first_arg}" != "" ]; then
        echo -e "ERROR:" $@ 1>&2
    fi
}

#------------------------------------------------------------------------------
# Print an warning message consiting of the concatenation of all arguments
#------------------------------------------------------------------------------
function warning {
    local first_arg=$(echo "$1" | awk '{gsub(/[[:blank:]]/, ""); print;}')
    if [ "${first_arg}" != "" ]; then
        echo -e "WARNING:" $@ 1>&2
    fi
}

function set_quiet {
    VERBOSE="${VERBOSE_QUIET}"
}

function set_verbose {
    if [ "${VERBOSE}" -le $VERBOSE_OUTPUT ]; then 
        export VERBOSE="${VERBOSE_SOMEWHAT}"
    elif [ "${VERBOSE}" == "${VERBOSE_SOMEWHAT}" ]; then 
        export VERBOSE="${VERBOSE_EXTRA}" 
    elif [ "${VERBOSE}" == "${VERBOSE_EXTRA}" ]; then 
        export VERBOSE="${VERBOSE_DEBUG}" 
    else 
        export VERBOSE="${VERBOSE_TRACE}" 
    fi
}

function writeln {
    if [ "${VERBOSE}" -ge $VERBOSE_OUTPUT ]; then
        echo -e "$@"  1>&2
    fi
}

function verbose {
    if [ "${VERBOSE}" -ge "${VERBOSE_SOMEWHAT}" ]; then
        echo -e "$@" 1>&2
    fi
}

function extra_verbose {
    if [ "${VERBOSE}" -ge "${VERBOSE_EXTRA}" ]; then
        echo -e "$@" 1>&2
    fi
}

function debug {
    if [ "${VERBOSE}" -ge "${VERBOSE_DEBUG}" ]; then
        echo -e "$@" 1>&2
    fi
}

function trace {
    if [ "${VERBOSE}" -ge "${VERBOSE_TRACE}" ]; then
        echo -e "$@" 1>&2
    fi
}

# =============================================================================
#  AWS (related) functions
# =============================================================================

function get_aws_profile {
    local profile="${AWS_PROFILE}"
    echo "${profile}"
}

function get_aws_region {
    local region="${AWS_REGION}" profile
    if [ "${region}" == "" ];  then
        profile=$(get_aws_profile)
        if [ "${profile}" != "" ]; then
            region=$(aws configure get region --profile "${profile}")
        fi 
        if [ "${region}" == "" ];  then
            region="us-east-1"
        fi
        # Make subsequent calls faster
        AWS_REGION="${region}"
    fi
    echo "${region}"
}

#------------------------------------------------------------------------------
#  Run aws cli command, adding a profile and regions as needed
#------------------------------------------------------------------------------
function do_aws {
    local region=$(get_aws_region)
    local aws_command="aws $* --region ${region}"
    trace "About to do [${aws_command}]"
    $aws_command
}

#------------------------------------------------------------------------------
#  Run aws cli s3 sub-command
#------------------------------------------------------------------------------
function s3 {
   do_aws s3 $*
}

#------------------------------------------------------------------------------
#  Run aws cli s3api sub-command
#------------------------------------------------------------------------------
function s3api {
   do_aws s3api $*
}

#------------------------------------------------------------------------------
#  Check is given S3 bucket exists
#------------------------------------------------------------------------------
function s3_bucket_exists {
    local name="$1"
    local exists=$(s3api head-bucket --bucket "${name}" 2>&1)
    debug "s3_bucket_exists: ${exists}"
    if [ "${exists}" == "" ]; then
        return 0
    fi
    return 1
}


# =============================================================================
#  Initialization functions
# =============================================================================

ACTION=""
BUCKET_NAME=""
BUCKET_PATH="terraform/"
BUCKET_URL=""
SOURCE_DIR=""
TARGET_DIR=""
STACK_NAME=""
BRANCH_NAME=""
INPUTS=()
OUTPUT_TYPE="tfvars" # DO NOT change

#------------------------------------------------------------------------------
#  Get unnamed argument, either stack or branch name (if not set yet)
#------------------------------------------------------------------------------
function get_argument {
    if [ "${STACK_NAME}" == "" ]; then
        debug "STACK_NAME=$1"
        STACK_NAME="$1"
    elif [ "${BRANCH_NAME}" == "" ]; then
        debug "BRANCH_NAME=$1"
        BRANCH_NAME="$1"
    else 
        error "Unknown argument '$1'"
        return 1
    fi
}

#------------------------------------------------------------------------------
#  Get action
#------------------------------------------------------------------------------
function get_action {
    local action="$1"
    case $action in
      create|delete)    ACTION="${action}" ;;
      *)                error "Unknown action '$action'"; return 1 ;;
    esac
}

#------------------------------------------------------------------------------
#  Get script parameters
#------------------------------------------------------------------------------
function get_parameters {
    while test $# -gt 0; do
        trace "Checking $1 (next: $2)"
        case $1 in
          -a|--action)          shift; get_action "$1" ;;
          -b|--bucket)          shift; BUCKET_NAME="$1" ;;
          -c|--bucket-path)     shift; BUCKET_PATH="$1" ;;
          -i|--input)           shift; INPUTS+=("$1") ;;
          -p|--profile)         shift; AWS_PROFILE="$1" ;;
          -r|--region)          shift; AWS_REGION="$1" ;;
          -q|--quiet)           set_quiet ;;
          -s|--source-dir)      shift; SOURCE_DIR="$1" ;;
          -t|--target_dir)      shift; TARGET_DIR="$1" ;;
          -v|--verbose)         set_verbose ;;
          *)                    get_argument "$1" || return 1 ;;
        esac
        shift
    done
}

#------------------------------------------------------------------------------
#  Initialize script by getting and validating parameters, as well 
#  as setting defaults as appropriate
#   - bucket:  Check that the given bucket name exists (default: data-gov)
#   - stack name: Ensure stack set (default: pilot)
#   - source-dir: Check that 'local' source directory exists 
#         (default: ./stack_name)
#   - target-dir: Create directory if not exists 
#          (default: ./target/stack/branch)
#------------------------------------------------------------------------------
function initialize {
    get_parameters "$@" || return 1
    if [ "${ACTION}" == "" ]; then
        ACTION="create"
    fi
    verbose "Using action ${ACTION}"
    if [ "${BUCKET_NAME}" == "" ]; then
        BUCKET_NAME="datagov-provisioning"
    fi
    if ! s3_bucket_exists "${BUCKET_NAME}" ; then
        error "Bucket '${BUCKET_NAME}' does not exist"
        return 1
    fi
    verbose "Using bucket ${BUCKET_NAME}"
    if [ "${STACK_NAME}" == "" ]; then
        STACK_NAME="pilot"
    fi
    verbose "Using stack ${STACK_NAME}"
    if [ "${SOURCE_DIR}" == "" ]; then
        SOURCE_DIR="${WORKING_DIR}/${STACK_NAME}"
    elif [ ! -d "${SOURCE_DIR}" ]; then
        error "Source directory '${SOURCE_DIR}' does not exist"
        return 2
    fi
    verbose "Using source directory ${SOURCE_DIR}"
    if [ "${BRANCH_NAME}" == "" ]; then
        BRANCH_NAME="master"
    fi
    verbose "Using branch ${BRANCH_NAME}"
    if [ "${TARGET_DIR}" == "" ]; then
        TARGET_DIR="${WORKING_DIR}/target/${STACK_NAME}/${BRANCH_NAME}"
    fi
    verbose "Using target directory ${TARGET_DIR}"
    BUCKET_URL="s3://${BUCKET_NAME}/${BUCKET_PATH}${STACK_NAME}"
    verbose "Using S3 location ${BUCKET_URL}"
    mkdir -p "${TARGET_DIR}"
    export AWS_REGION
    export AWS_PROFILE
}

# =============================================================================
#  Main
# =============================================================================

#------------------------------------------------------------------------------
#  Get any (existing) stack-branch specific state from S3 bucket 
#------------------------------------------------------------------------------
function get_state {
    writeln "Get '${STACK_NAME}' state"
    rm -rf "${TARGET_DIR}"
    s3 sync "${BUCKET_URL}/${BRANCH_NAME}" "${TARGET_DIR}" || return 1
}

#------------------------------------------------------------------------------
#  Put any (existing) stack-branch specific state from S3 bucket 
#------------------------------------------------------------------------------
function put_state {
    local action="$1" s3uri="${BUCKET_URL}/${BRANCH_NAME}"
    if [ "${ACTION}" == "delete" ]; then
        writeln "Remove '${STACK_NAME}' state"
        s3 rm --recursive "${s3uri}" || return 1
    else
        writeln "Preserve '${STACK_NAME}' state"
        s3 sync "${TARGET_DIR}" "${s3uri}" || return 2
    fi
}


#------------------------------------------------------------------------------
#  Input handling
#------------------------------------------------------------------------------

function get_modules {
    # Always remove modules to ensure proper update
    # See https://github.com/hashicorp/terraform/issues/3070
    extra_verbose "Removing 'downloaded' terraform modules"
    rm -rf ./.terraform
    writeln "Update '${STACK_NAME}' modules"
    terraform get "${SOURCE_DIR}" || return 1
    pushd ./.terraform
    extra_verbose "Replace .terraform symbolic links with actual targets"
    # Symbolic links seem to cause the originals to get updated/reverted to
    # a previous (cached?) version when running this script
    find -type l -exec \
        sh -c 'TARGET=$(realpath -- "$1") && rm -- "$1" && cp -ar -- "$TARGET" "$1"' \
        resolver {} \;
    popd
}

function to_input_url {
    local url="$1"
    local mapped_url=$(echo "${url}" | awk \
        -v BUCKET_NAME="${BUCKET_NAME}" \
        -v BUCKET_PATH="${BUCKET_PATH}" \
        -v OUTPUT_TYPE="${OUTPUT_TYPE}" '
        /^stack-output:\/\// {
            split(substr($0, length("stack-output://") + 1), parts, "/");
            bucket_name = (parts[1] != "") ? parts[1] : BUCKET_NAME;
            stack_name = parts[2];
            branch_name = parts[3];
            printf("s3://%s/%s%s/%s/%s-output.%s", bucket_name, BUCKET_PATH,
                stack_name, branch_name, stack_name, OUTPUT_TYPE);
            exit;
        }
        {
            gsub(/^file:\/\//, $0);
            printf("%s", $0);
            exit;
        }
        ')
    if [ ! $? -eq 0 ]; then
        return 1
    elif [ "${url}" != "${mapped_url}" ] ; then
        verbose "    => ${mapped_url}"
    fi
    echo "${mapped_url}"
}

function get_filename {
    local file_name=
    writeln "FILENAME=[${file_name}]"
    echo "${file_name}"
}

function get_s3_input {
    local url="$1"
    local file_name="$2"
    extra_verbose "Copying ${url} to ${file_name}"
    if ! s3 cp --only-show-errors "${url}" "${file_name}" ; then
        error "Failed to copy ${url} to ${file_name}"
        return 1
    fi
    echo "${file_name}"
}

function get_http_input {
    local url="$1"
    local file_name="$2"
    extra_verbose "Copying ${url} to ${file_name}"
    if ! curl --max-redirs 100 -s -K -L "${url}" -o "${file_name}" ; then
        error "Failed to copy ${url} to ${file_name}"
        return 1
    fi
    echo "${file_name}"
}

function get_input {
    local input="$1" 
    local action="$2"
    local input_file=$(to_input_url "${input}")
    local local_file=$(echo "${input_file}" | awk -F "/" \
            -v TARGET_DIR="${TARGET_DIR}" \
            '{printf("%s/%s", TARGET_DIR, $NF);}')
    extra_verbose "get input ${input_file} into ${local_file}"
    if [ "${action}" == "create" ]; then
        case $input_file in
            s3://*)
                get_s3_input "${input_file}" "${local_file}" || return 1 ;;
            http://*|https://*)
                get_http_input "${input_file}" "${local_file}" || return 2 ;;
        esac
    fi
    if [ ! -f "${local_file}" ]; then
        error "Input ${local_file} does not exist"
        return 2
    else 
        extra_verbose "LOcal input file ${local_file} exists"
    fi
    echo "${local_file}"
}

#------------------------------------------------------------------------------
#  Apply stack
#------------------------------------------------------------------------------

function apply_stack {
    writeln "Apply '${STACK_NAME}'"
    terraform apply $@ || return 1
}

#------------------------------------------------------------------------------
#  Output handling
#------------------------------------------------------------------------------

function convert_to_hcl {
    awk '
        / = / { 
            split($0, parts, " = ");
            # quote variables
            printf("%s = \"%s\"\n", parts[1], parts[2]);
        }
        '
}

function create_output {
    writeln "Generate '${STACK_NAME}' output"
    terraform output -state "${STACK_NAME}.tfstate" | convert_to_hcl \
        > "${STACK_NAME}-output.${OUTPUT_TYPE}" || return 1
}

#------------------------------------------------------------------------------
#  Create a stack from the given source directory to the given target 
#  directory
#------------------------------------------------------------------------------
function create_stack {
    writeln "Creating terraform stack '${STACK_NAME}'"
    get_modules || return 1
    apply_stack $@ || return 2
    create_output || return 3
}

#------------------------------------------------------------------------------
#  Delete a stack from the given source directory to the given target 
#  directory
#------------------------------------------------------------------------------

function delete_stack {
    if [ -f "${STACK_NAME}.tfstate" ]; then
        writeln "Deleting stack '${STACK_NAME}'"
        terraform destroy -force $@ || return 1
        rm -f "${STACK_NAME}.tfstate*" "${STACK_NAME}-output.*"
        rm -rf "./terraform"
    else
        writeln "Terraform stack '${STACK_NAME}' does not exist." \
            "Nothing to delete."
    fi
}

function do_stack {
    # Ensure that directory stack is popped regardless of the success
    # (or failure) of create_stack function
    local action="$1"
    local stack_args=() input_files variables_file input 
    writeln "${action} stack '${STACK_NAME}' in ${TARGET_DIR}"
    stack_args+=("-var branch=${BRANCH_NAME}")
    stack_args+=("-var stack=${STACK_NAME}")
    stack_args+=("-input=false")
    extra_verbose "Checking for inputs in ${SOURCE_DIR}"
    # Allow json and tfvar files as input
    input_files=$(find "${SOURCE_DIR}" -iregex ".*\.\(tfvars\|json\)" -printf "%f")
    for variables_file in $input_files ; do
        verbose "Adding input from ${variables_file}"
        stack_args+=("-var-file ${SOURCE_DIR}/${variables_file}")
    done
    extra_verbose "Adding provided inputs"
    for input in ${INPUTS[@]} ; do
        verbose "Adding input from ${input}"
        variables_file=$(get_input "${input}" "${action}")
        if [ ! $? -eq 0 ]; then return 1; fi
        extra_verbose "Adding ${variables_file}"
        stack_args+=("-var-file ${variables_file}")
    done
    stack_args+=("-state ${STACK_NAME}.tfstate")
    stack_args+=("${SOURCE_DIR}")
    local status=0
    pushd "${TARGET_DIR}" 1> /dev/null
    extra_verbose "About to [${action}_stack ${stack_args[@]}]"
    "${action}_stack" ${stack_args[@]}
    status=$?
    popd 1> /dev/null
    return $status
}


#------------------------------------------------------------------------------
#  Main body
#------------------------------------------------------------------------------
STACK_STATUS=0
initialize "$@" || exit 1
get_state || exit 2
do_stack "${ACTION}" || exit 3
put_state "${ACTION}" || exit 4

