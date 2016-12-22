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
    writeln "Preserve '${STACK_NAME}' state"
    s3 sync "${TARGET_DIR}" "${BUCKET_URL}/${BRANCH_NAME}" || return 1
}

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

#------------------------------------------------------------------------------
#  Create a stack from the given source directory to the given target 
#  directory
#------------------------------------------------------------------------------
function create_stack {
    writeln "Creating terraform stack '${STACK_NAME}'"
    get_modules || return 2
    writeln "Apply '${STACK_NAME}'"
    terraform apply $@ || return 3
    writeln "Generate '${STACK_NAME}' output"
    terraform output -state "${STACK_NAME}.tfstate" > "${STACK_NAME}-output.tvar" || return 4
}

#------------------------------------------------------------------------------
#  Delete a stack from the given source directory to the given target 
#  directory
#------------------------------------------------------------------------------

function delete_stack {
    if [ -f "${STACK_NAME}.tfstate" ]; then
        writeln "Deleting stack '${STACK_NAME}'"
        terraform destroy -force $@ || return 1
        rm -f "${STACK_NAME}.tfstate*" "${STACK_NAME}-output.tvar" 
        rm -rf "./terraform"
    else
        writeln "Terrform stack '${STACK_NAME}' does not exist. Nothing to delete."
    fi
}

function do_stack {
    # Ensure that directory stack is popped regardless of the success
    # (or failure) of create_stack function
    local action="$1"
    local stack_args=()
    writeln "${action} stack '${STACK_NAME}' in ${TARGET_DIR}"
    stack_args+=("-var branch=${BRANCH_NAME}")
    stack_args+=("-var stack=${STACK_NAME}")
    stack_args+=("-input=false")
    if [ -f "${SOURCE_DIR}/terraform.tfvars" ]; then
        extra_verbose "Found ${SOURCE_DIR}/terraform.tfvars"
        stack_args+=("-var-file ${SOURCE_DIR}/terraform.tfvars")
    fi
    stack_args+=("-state ${STACK_NAME}.tfstate")
    stack_args+=("${SOURCE_DIR}")
    local status=0
    pushd "${TARGET_DIR}" 1> /dev/null
    verbose "About to [${action}_stack ${stack_args[@]}]"
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
put_state || exit 4

