#!/bin/sh

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
    if [ "${profile}" == "" ];  then
        profile="default"
        # Make next call faster
        AWS_PROFILE="${profile}"
    fi
    echo "${profile}"
}

function get_aws_region {
    local region="${AWS_REGION}" profile
    if [ "${region}" == "" ];  then
        profile=$(get_aws_profile)
        if [ "${profile}" != "" ]; then
            region=$(aws configure get region --profile $profile)
        else 
            region="us-east-1"
        fi
        # Make subsequent calls faster
        AWS_REGION="${region}"
    fi
    echo "${region}"
}

function do_aws {
    local profile=$(get_aws_profile)
    local region=$(get_aws_region)
    local aws_command="aws $* --profile ${profile} --region ${region}"
    trace "About to do [${aws_command}]"
    $aws_command
}

function s3 {
   do_aws s3 $*
}

function s3api {
   do_aws s3api $*
}

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

BUCKET_NAME="data-gov"
BUCKET_PATH="terraform/"
BUCKET_URL=""
SOURCE_DIR=""
TARGET_DIR=""
STACK_NAME=""
BRANCH_NAME=""

function get_argument {
    if [ "${STACK_NAME}" == "" ]; then
        STACK_NAME="$1"
    elif [ "${BRANCH_NAME}" == "" ]; then
        BRANCH_NAME="$1"
    else 
        error "Unknown argument '$1'"
        return 1
    fi
}

function get_parameters {
    while test $# -gt 0; do
        trace "Checking $1 (next: $2)"
        case $1 in
          -b|--bucket)          shift; set BUCKET_NAME="$1" ;;
          -c|--bucket-path)     shift; set BUCKET_PATH="$1" ;;
          -d|--destroy)         shift; set DESTROY="$1" ;;
          -p|--profile)         shift; set AWS_PROFILE="$1" ;;
          -r|--region)          shift; set AWS_REGION="$1" ;;
          -q|--quiet)           set_quiet ;;
          -s|--source-dir)      shift; set SOURCE_DIR="$1" ;;
          -t|--target_dir)      shift; set TARGET_DIR="$1" ;;
          -v|--verbose)         set_verbose ;;
          *)                    get_argument "$1" || return 1 ;;
        esac
        shift
    done
}

function initialize {
    get_parameters "$@" || return 1
    if [ "${BUCKET_NAME}" == "" ]; then
        BUCKET_NAME="data-gov"
    fi
    if ! s3_bucket_exists "${BUCKET_NAME}" ; then
        error "Bucket '${BUCKET_NAME}' does not exist"
        return 1
    fi
    if [ "${STACK_NAME}" == "" ]; then
        STACK_NAME="pilot"
    fi
    if [ "${SOURCE_DIR}" == "" ]; then
        SOURCE_DIR="${WORKING_DIR}/${STACK_NAME}"
    elif [ ! -d "${SOURCE_DIR}" ]; then
        error "Source directory '${SOURCE_DIR}' does not exist"
        return 2
    fi
    if [ "${BRANCH_NAME}" == "" ]; then
        BRANCH_NAME="master"
    fi
    if [ "${TARGET_DIR}" == "" ]; then
        TARGET_DIR="${WORKING_DIR}/target/${STACK_NAME}/${BRANCH_NAME}"
    fi
    BUCKET_URL="s3://${BUCKET_NAME}/${BUCKET_PATH}${STACK_NAME}"
    mkdir -p "${TARGET_DIR}"
}

# =============================================================================
#  Main
# =============================================================================

function get_state {
    writeln "Get '${STACK_NAME}' state"
    s3 sync "${BUCKET_URL}/${BRANCH_NAME}" "${TARGET_DIR}" || return 1
}

function put_state {
    writeln "Preserve '${STACK_NAME}' state"
    s3 sync "${TARGET_DIR}" "${BUCKET_URL}/${BRANCH_NAME}" || return 1
}

function create_stack {
    local extra_args
    writeln "Creating terraform stack '${STACK_NAME}'"
    pushd "${TARGET_DIR}" 1> /dev/null
    if [ "${DESTROY}" != "" ]; then
        writeln "Destroying old terraform stack '${STACK_NAME}'"
        terraform destroy -force
        rm -rf ./.terraform
    fi
    writeln "Update '${STACK_NAME}' modules"
    terraform get -update "${SOURCE_DIR}"
    writeln "Apply '${STACK_NAME}'"
    if [ -f "${SOURCE_DIR}/terraform.tfvars" ]; then
        extra_args="-var-file ${SOURCE_DIR}/terraform.tfvars"
    fi
    terraform apply -var "branch=${BRANCH_NAME}" -var "stack=${STACK_NAME}" -input=false \
        -state "${TARGET_DIR}/${STACK_NAME}.tfstate" $extra_args "${SOURCE_DIR}"
    writeln "Generate '${STACK_NAME}' output"
    terraform output -state "${TARGET_DIR}/${STACK_NAME}.tfstate" > \
        "${TARGET_DIR}/${STACK_NAME}-output.tvar"
    popd 1> /dev/null
}


initialize "$@" || exit 1
get_state || exit 2
create_stack || exit 3
put_state || exit 4

