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
#  Run aws cli ec2 sub-command
#------------------------------------------------------------------------------
function ec2 {
   do_aws ec2 $*
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
#  Utility functions
# =============================================================================

function join_by { 
    local separator="$1" joined="" index=1 e=""
    shift
    for e in $*; do
        if [ "${index}" -gt 1 ]; then
            joined="${joined}${separator}"
        fi
        joined="${joined}${e}"
        ((++index))
    done
    echo -e "${joined}"
}

# =============================================================================
#  Configuration functions
# =============================================================================

PROPERTIES_FS="."

#-------------------------------------------------------------------------------
# Converts yaml to a properties file, so configuration information can be read 
# by using properties (simpler with bash only, see get_property)
#-------------------------------------------------------------------------------
function parse_yaml {
    local file_name=$1
    local prefix=$2
    if  [ ! -f "${file_name}" ]; then
       echo "File '${file_name}' does not exist" >&2
       exit 1
    fi
    debug "config-data(file):\n$(cat $file_name)\n"
    cat $file_name | parse_yaml_from_string
}

function parse_yaml_from_string {
    local s='[[:space:]]*'
    local w='[.a-zA-Z0-9_\-]*'
    local fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\):\$|\1|" \
        -e "/^\($s\)\#/d" \
        -e "s|^\($s\)\(- \)\?\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\3$fs\4|p" \
        -e "s|^\($s\)\(- \)\?\($w\)$s:$s\(.*\)$s\$|\1$fs\3$fs\4|p" \
        -e "s|^\($s\)\(- \)\($w\)$s\$|\1$fs\3$fs\3|p" \
        $file_name | \
        awk -F$fs -vprefix="${prefix}" -vyamlToPropertiesFS="${PROPERTIES_FS}" '{
            if (NR == 1) {
                indent_size=2;
            } else if (NR == 2) {
                indent_size=length($1);
            }
            # print $1"::"$2"::"$3 >> "/dev/stderr";
            indent = length($1)/indent_size;
            vname[indent] = $2;
            for (i in vname) { if (i > indent) { delete vname[i]; } }
            if (length($3) > 0) {
                vn="";
                for (i=0; i<indent; i++) { vn=(vn)(vname[i])(yamlToPropertiesFS);}
                printf("%s%s%s%s%s\n", prefix, vn, $2, (($3 == "") ? "" : "="), $3);
            }
        }'
}

function get_property {
    local propertyRE="^$1="
    local config="${2}"
    local default_value="$3"
    if [ "${config}" == "" ]; then
        error "No configuration data given"
        return 1
    else
        debug "config=[${config}]"
    fi
    local value=$(echo -e "${config}" | \
        awk -F "=" -v propertyRE="${propertyRE}" '$0 ~ propertyRE {print $2;}')
    if [ "${value}" == "" ]; then
        value="${default_value}"
    fi
    debug "get_property $1 = [${value}]"
    echo -e "${value}"
}


function get_property_names {
    local name="$1"
    local config="${2}"
    local elements=$(echo -e "${config}" | awk -vNAME="${name}" \
         -F"${PROPERTIES_FS}" '
      /^'"${name}"'/ {
        name = "";
        for (i = 1; i <= NF; i++) {
          if (name == NAME) { p = $i; gsub(/[=](.*)$/, "", p); print p; break; }
          if (i > 1) { name = name FS; }
          name = name $i
        }
    }' | uniq)
    join_by " " $elements
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
ENVIRONMENT_NAME=""
INPUTS=()
OUTPUT_TYPE="tfvars" # DO NOT change
STACK_CONFIG=""
NO_WAIT=""
RESOURCES_READY=""

#------------------------------------------------------------------------------
#  Get unnamed argument, either stack or environment name (if not set yet)
#------------------------------------------------------------------------------
function get_argument {
    if [ "${STACK_NAME}" == "" ]; then
        debug "STACK_NAME=$1"
        STACK_NAME="$1"
    elif [ "${ENVIRONMENT_NAME}" == "" ]; then
        debug "ENVIRONMENT_NAME=$1"
        ENVIRONMENT_NAME="$1"
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


function set_nowait {
    NO_WAIT="yes"
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
          -n|--no-wait)         set_nowait ;;
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
#          (default: ./target/stack/environment)
#------------------------------------------------------------------------------
function initialize {
    local config_data
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
    if [ "${ENVIRONMENT_NAME}" == "" ]; then
        ENVIRONMENT_NAME="prod"
    fi
    verbose "Using environment ${ENVIRONMENT_NAME}"
    if [ "${TARGET_DIR}" == "" ]; then
        TARGET_DIR="${WORKING_DIR}/target/${STACK_NAME}/${ENVIRONMENT_NAME}"
    fi
    verbose "Using target directory ${TARGET_DIR}"
    BUCKET_URL="s3://${BUCKET_NAME}/${BUCKET_PATH}${STACK_NAME}"
    verbose "Using S3 location ${BUCKET_URL}"

    if [ "${NO_WAIT}" == "" ] && [ "${ACTION}" == "create" ]; then
        STACK_CONFIG=$(parse_yaml "${SOURCE_DIR}/stack.yml")
    fi
    debug "STACK_CONFIG=[\n${STACK_CONFIG}\n]"

    mkdir -p "${TARGET_DIR}"
    export AWS_REGION
    export AWS_PROFILE
}


# =============================================================================
#  Main
# =============================================================================

#------------------------------------------------------------------------------
#  Get any (existing) stack-environment specific state from S3 bucket 
#------------------------------------------------------------------------------
function get_state {
    writeln "Get '${STACK_NAME}' state"
    rm -rf "${TARGET_DIR}"
    s3 sync "${BUCKET_URL}/${ENVIRONMENT_NAME}" "${TARGET_DIR}" || return 1
}

#------------------------------------------------------------------------------
#  Put any (existing) stack-environment specific state from S3 bucket 
#------------------------------------------------------------------------------
function put_state {
    local action="$1" s3uri="${BUCKET_URL}/${ENVIRONMENT_NAME}"
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
    local status=0
    # Always remove modules to ensure proper update
    # See https://github.com/hashicorp/terraform/issues/3070
    extra_verbose "Removing 'downloaded' terraform modules"
    rm -rf ./.terraform
    writeln "Update '${STACK_NAME}' modules"
    terraform get "${SOURCE_DIR}" || return 1
    pushd ./.terraform 1> /dev/null
    extra_verbose "Replace .terraform symbolic links with actual targets"
    # Symbolic links seem to cause the originals to get updated/reverted to
    # a previous (cached?) version when running this script
    find -type l -exec \
        sh -c 'TARGET=$(realpath -- "$1") && rm -- "$1" && cp -ar -- "$TARGET" "$1"' \
        resolver {} \; || status=$?
    popd 1> /dev/null
    return $status
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
            environment_name = parts[3];
            printf("s3://%s/%s%s/%s/%s-output.%s", bucket_name, BUCKET_PATH,
                stack_name, environment_name, stack_name, OUTPUT_TYPE);
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
}

function get_http_input {
    local url="$1"
    local file_name="$2"
    extra_verbose "Copying ${url} to ${file_name}"
    if ! curl --max-redirs 100 -s -K -L "${url}" -o "${file_name}" ; then
        error "Failed to copy ${url} to ${file_name}"
        return 1
    fi
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
    local status=0
    writeln "Creating terraform stack '${STACK_NAME}'"
    pushd "${TARGET_DIR}" 1> /dev/null
    get_modules && apply_stack $@ && create_output
    status=$?
    popd 1> /dev/null
    return $status
}

#------------------------------------------------------------------------------
#  Delete a stack from the given source directory to the given target 
#  directory
#------------------------------------------------------------------------------

function delete_stack {
    local status=0

    writeln "Deleting stack '${STACK_NAME}'"
    pushd "${TARGET_DIR}" 1> /dev/null
    if [ -f "${TARGET_DIR}/${STACK_NAME}.tfstate" ]; then
        terraform destroy -force $@ || status=1
    else
        writeln "No state found. Nothing to delete"
    fi
    if [ $status -eq 0 ]; then
        verbose "Delete stack '${STACK_NAME}' target directory ${TARGET_DIR}"
        if rm -rf "${TARGET_DIR}" ; then
            extra_verbose "Stack '${STACK_NAME}' target directory ${TARGET_DIR} deleted"
        else 
            status=2
        fi
    fi
    popd 1> /dev/null
    return $status
}

function do_stack {
    # Ensure that directory stack is popped regardless of the success
    # (or failure) of create_stack function
    local action="$1" work_dir=$(pwd) status=0
    local stack_args=() input_files variables_file input 
    writeln "${action} stack '${STACK_NAME}' in ${TARGET_DIR}"
    if [ "${action}" != "delete" ] ||
       [ -f "${TARGET_DIR}/${STACK_NAME}.tfstate" ]
    then
        stack_args+=("-var environment=${ENVIRONMENT_NAME}")
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
    #else: Nothing to delete 
    fi
    extra_verbose "About to [${action}_stack ${stack_args[@]}]"
    pushd "${work_dir}" 1> /dev/null
    "${action}_stack" ${stack_args[@]} 
    status=$?
    popd 1> /dev/null
    return $status
}


function instance_passes_healthcheck {
    local resource="$1" status
    # Find the instance
    local instanceID=$(ec2 describe-instances \
            --filter "Name=tag:System,Values=datagov" \
                     "Name=tag:Stack,Values=${STACK_NAME}" \
                     "Name=tag:Environment,Values=${ENVIRONMENT_NAME}" \
                     "Name=tag:Resource,Values=${resource}" \
                     "Name=instance-state-name,Values=running" \
            --query "Reservations[].Instances[].{Id:InstanceId}" \
            --output text)
    if [ "${instanceID}" == "" ]; then
        debug "Resource ${resource} not found"
        return 1
    fi
    # Check the health-check status
    status=$(ec2 describe-instance-status \
        --instance-ids "${instanceID}" \
        --filter "Name=instance-state-name,Values=running" \
                 "Name=instance-status.reachability,Values=passed" \
                 "Name=system-status.reachability,Values=passed" \
        --query "InstanceStatuses[].{Id:InstanceId}" \
        --output text)
    if [ "${status}" == "" ]; then
        debug "Resource ${resource} health checks not passed"
        return 1
    fi
    debug "Resource ${resource} health checks passed"
    return 0
}

function all_resources_completed {
    local elapsed="$1"
    local conditions="$2"
    local n_failures=0 name condition reported
    for name in $conditions ; do
        condition=$(get_property "stack.wait.conditions.${name}" \
            "${STACK_CONFIG}")
        debug "Checking ${condition} on ${name}"
        case $condition in
            aws-healthcheck)
                if ! instance_passes_healthcheck "${name}" ; then
                    writeln "Resource ${name} not ready (${condition}) " \
                        "(${elapsed}s elapsed)"
                    (( n_failures += 1 ))
                else 
                    reported=$(echo "${RESOURCES_READY}" | grep "${name}")
                    if [ "${reported}" == "" ]; then
                       RESOURCES_READY="${RESOURCES_READY} ${name}"
                        writeln "Resource ${name} is ready (${condition})"
                    fi
                fi
                ;;
            *)  
                error "Unknown wait condition ${condition}"
                return 1
                ;;
        esac
    done
    return $n_failures
}

function wait_for_completion {
    local delay max_iterations i=0 resources
    local default_delay=15 default_iterations elapsed=0
    if [ "${STACK_CONFIG}" == "" ]; then
        return 0
    fi
    resources=$(get_property_names "stack.wait.conditions" "${STACK_CONFIG}")
    if [ "${resources}" == "" ]; then
        writeln "No resources to wait for found in stack.yml"
        return 0
    fi
    extra_verbose "Waiting for [${resources}] to complete"
    # delay in seconds
    delay=$(get_property "stack.wait.delay" "${STACK_CONFIG}" "30")
    # default is 2 hours 
    (( default_iterations = 2 * 60 * 60 / $delay ))
    max_iterations=$(get_property "stack.wait.max-iterations" \
       "${STACK_CONFIG}" "${default_iterations}")
    debug "i=$i; max_iterations=$max_iterations"
    while [ "${i}" -lt "${max_iterations}" ] &&
          ! all_resources_completed "${elapsed}" "${resources}";
    do
        sleep "${delay}"
        (( i += 1 ))
        (( elapsed = i * delay ))
    done
}

function do_terraform {
    get_state || return 1
    do_stack "${ACTION}" || return 2
    put_state "${ACTION}" || return 3
}

#------------------------------------------------------------------------------
#  Main body
#------------------------------------------------------------------------------
initialize "$@" || exit 1
do_terraform || exit 2
wait_for_completion || exit 3
