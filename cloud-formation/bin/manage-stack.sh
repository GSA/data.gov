#!/usr/bin/env bash

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR=$(dirname $0)

ACTION_CREATE="create"
ACTION_DELETE="delete"
ACTION_VERIFY="verify"
ACTION="${ACTION_CREATE}"
CONFIG_DATA=
CLEANUP="true"
BUCKET_NAME=
BUCKET_REGION=
MASTER_TEMPLATE=
STACK_POLICY=
STACK_NAME=
STACK_ID=
STACK_TEMPLATES=
STACK_PARAMETERS=
STACK_SCRIPTS=
STACK_PATH=""
SOURCE_DIRS=""
TARGET_DIR=""
ENVIRONMENT=""
SECURITY_CONTEXT=""
STACK_INPUTS=()

function usage {
    cat "${SCRIPT_DIR}/usage.txt"
}

function source_script {
    local script="$1"
    local script_dir="$2"
    if [ -f "${script_dir}/${script}" ]; then
        source "${script_dir}/${script}"
    else
        echo -n "Supporting script '${script}' not found in '${script_dir}' " >&2
        return 1
    fi
}

# =============================================================================
#  ERROR functions
# =============================================================================

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

#------------------------------------------------------------------------------
# Print an error message read from stdin and exits.
#------------------------------------------------------------------------------
function exit_error {
    local message="$@" line
    if [ "${message}" == "" ]; then
        while read line; do
            message="${message}${line}"
        done
    fi
    error "${message}"
    exit 1
}

function onerror_exit {
    local code=$1
    if [ "$1" != "0" ]; then
        shift
        echo -e "$*" | exit_error
    fi
}

# =============================================================================
#  LOG functions
# =============================================================================

LOG_LEVEL=1

function set_log_file {
    LOG_FILE="$1"
}

function set_log_level {
    LOG_LEVEL="$1"
}

function log {
    local now="$(get_timestamp --format '%Y-%m-%d %H:%M:%S,%3N')"
    if [ "${LOG_FILE}" != "" ]; then
        echo -e "[${now}] " $* >> ${LOG_FILE}
    fi
}

function log_section {
    log "=============== $1 ==============="
}

# =============================================================================
#  OUTPUT (VERBOSITY) functions
# =============================================================================

VERBOSE_QUIET="0"
VERBOSE_OUTPUT="1"
VERBOSE_SOMEWHAT="2"
VERBOSE_EXTRA="3"
VERBOSE_DEBUG="4"
VERBOSE_TRACE="5"
VERBOSE="${VERBOSE_OUTPUT}"

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
    if [ "${LOG_LEVEL}" -ge $VERBOSE_OUTPUT ]; then
        log "$@"
    fi
    if [ "${VERBOSE}" -ge $VERBOSE_OUTPUT ]; then
        echo -e "$@"  1>&2
    fi
}

function verbose {
    if [ "${LOG_LEVEL}" -ge "${VERBOSE_SOMEWHAT}" ]; then
        log "$@"
    fi
    if [ "${VERBOSE}" -ge "${VERBOSE_SOMEWHAT}" ]; then
        echo -e "$@" 1>&2
    fi
}

function extra_verbose {
    if [ "${LOG_LEVEL}" -ge "${VERBOSE_EXTRA}" ]; then
        log "$@"
    fi
    if [ "${VERBOSE}" -ge "${VERBOSE_EXTRA}" ]; then
        echo -e "$@" 1>&2
    fi
}

function debug {
    if [ "${LOG_LEVEL}" -ge "${VERBOSE_DEBUG}" ]; then
        log "$@"
    fi
    if [ "${VERBOSE}" -ge "${VERBOSE_DEBUG}" ]; then
        echo -e "$@" 1>&2
    fi
}

function trace {
    if [ "${LOG_LEVEL}" -ge "${VERBOSE_TRACE}" ]; then
        log "$@"
    fi
    if [ "${VERBOSE}" -ge "${VERBOSE_TRACE}" ]; then
        echo -e "$@" 1>&2
    fi
}



# =============================================================================
#  CONFIGURATION functions
# =============================================================================

PROPERTIES_FS="__"

function set_config_file {
    CONFIG_FILE="$1"
}

function parse_yaml {
    local file_name=$1
    local prefix=$2
    if  [ ! -f "${file_name}" ]; then
       echo "File '${file_name}' does not exist" >&2
       exit 1
    fi
    trace "config-data(file):\n$(cat $file_name)\n"
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
        -e "s|^\($s\)\(- \)\($w\)$s\$|\1$fs\3$fs\3|p" | \
        awk -F$fs -vprefix="${prefix}" -vyamlToPropertiesFS="${PROPERTIES_FS}" '{
            if (NR == 1) {
                indent_size=2;
            } else if (NR == 2) {
                indent_size=length($1);
            }
            #print $1"::"$2"::"$3 >> "/dev/stderr";
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

function get_config_data {
    local w='[a-zA-Z0-9_-]*' location file_name is_yaml region_arg tmpdir_arg config_data
    while test $# -gt 0; do
        trace "get_config_data: checking parameter '$1'"
        case $1 in
          --region)     shift; if [ "$1" != "" ]; then region_arg="--region $1"; fi ;;
          --tmpdir)     shift; tmpdir_arg="--tmpdir $1" ;;
          *)            if [ "${location}" == "" ]; then
                            location="$1"
                        else
                            error "get_config_data: Unknown argument '$1'"
                            return 1
                        fi
                        ;;
        esac
        shift
    done
    if ! file_name=$(get_file "${location}" $region_arg $tmpdir_arg); then
        return 1
    fi
    is_yaml=$(cat "${file_name}" | grep "^${w}:$")
    if [ "${is_yaml}" != "" ]; then
        writeln "Using yaml configuration file '${location}'"
        config_data=`parse_yaml "${file_name}"`
    else 
        writeln "Using properties configuration file '${location}'"
        config_data=`cat "${file_name}"`
    fi
    trace "get_config_data:\n${config_data}\n"
    echo -e "${config_data}"
}

function get_property_name {
    local line="$1"
    echo "${line}" | awk -F"=" '{print $1;}'
}

function get_property {
    local propertyRE="^$1="
    local config="${2}"
    local value=$(echo -e "${config}" | \
        awk -F "=" -v propertyRE="${propertyRE}" '$0 ~ propertyRE {print $2;}')
    trace "get_property $1 = [${value}]"
    echo -e "${value}"
}

function get_properties {
    local propertyRE="^$1.*="
    local config="${2}"
    local lines=$(echo -e "${config}" | \
        awk -F "=" -v propertyRE="${propertyRE}" '$0 ~ propertyRE {print $2;}')
    trace "get_property $1 = [${lines}]"
    echo -e "${lines}"
}

function create_property_name {
    local name="" postfix=""
    if [ "$1" == "--prefix" ]; then
        postfix="${PROPERTIES_FS}"
        shift;
    fi
    for segment in $@; do
        if [ "${name}" != "" ]; then 
            name="${name}${PROPERTIES_FS}"
        fi
        name="${name}${segment}"
    done
    name="${name}${postfix}"
    echo "${name}"
}

function get_property_names {
    local name="$1"
    local config="${2}"
    local elements=$(echo -e "${config}" | awk -vNAME="${name}" \
         -F"${PROPERTIES_FS}" '
      /^'"${name}"'/ {
        name = "";
        for (i = 1; i <= NF; i++) {
          if (name == NAME) { p = $i; gsub(/[=](.*)$/, "", p); print p;  break; }
          if (i > 1) { name = name FS; }
          name = name $i
        }
    }' | uniq)
    join_by " " $elements
}

function get_property_name_without_context {
    local name="$1"
    echo "${name}" | awk -F"${PROPERTIES_FS}" '{print $NF;}'
}

function get_parameter {
    local property="$1"
    local text="$2"
    local default_value="$3"
    local property_regex="^${property}="
    local value=`echo "${text}" | awk -F "=" -v property_regex="${property_regex}" '
            $0 ~ property_regex {gsub(property_regex, "", $0); print $0}'`
    if [ "${value}" == "" ]; then
        value="${default_value}"
    fi
    echo -e "${value}"
}


# =============================================================================
#  UTILITY functions
# =============================================================================

function echo_stdin {
    local trim="$1"
    if [ "${trim}" != "" ]; then
        while read line ; do echo -e $line ; done
    else
        cat
    fi
}

function get_timestamp {
    local when="now"
    local date_format="%Y-%m-%dT%H:%M:%S.000Z"
    while test $# -gt 0; do
        trace "get_timestamp: checking parameter '$1'"
        case $1 in
          --when)     shift; when=`echo "$1" | trim` ;;
          --format)   shift; date_format=`echo "$1" | trim` ;;
          *)          error "get_timestamp: Unknown argument '$1'"; return 1 ;;
        esac
        shift
    done
    trace "get_timestamp ${when} +${date_format}"
    TZ='${TIMEZONE}' date "--date=${when}" +"${date_format}"
}

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

function toupper {
    echo -e "$1" | awk '{print toupper($0);}'
}

function tolower {
    echo -e "$1" | awk '{print tolower($0);}'
}

function trim_trail {
    local value=`sed -e 's/[[:space:]]*$//'`
    trace "trim_trail($1)=${value}"
    echo -e "${value}"
}
function trim_lead {
    local value=`sed -e 's/^[[:space:]]*//'`
    trace "trim_lead($1)=${value}"
    echo -e "${value}"
}
function trim {
    local value=`trim_trail | trim_lead`
    trace "trim($1)=${value}"
    echo -e "${value}"
}

function get_file {
    local file_name region tmpdir local_file_name
    while test $# -gt 0; do
        trace "get_file: checking parameter '$1'"
        case $1 in
          --region)     shift; region=`echo "$1" | trim` ;;
          --tmp-dir)    shift; tmpdir="--tmpdir=="`echo "$1" | trim` ;;
          *)            if [ "${file_name}" == "" ]; then
                            file_name="$1"
                        else
                            error "get_file: Unknown argument '$1'"
                            return 1
                        fi
                        ;;
        esac
        shift
    done
    if [ "${tmpdir}" != "" ]; then
        tmpdir="--tmpdir=${tmpdir}"
    fi
    if [[ $file_name == s3://* ]]; then
        if [ "${region}" == "" ] && [ "${AWS_DEFAULT_REGION}" == "" ]; then
            error "get_file: No region provided to retrieve ${file_name}" \
                "(use --region or set variable AWS_DEFAULT__REGION)."
            return 2
        fi
        trace "get_file: S3 from ${region}"
        local_file_name=`mktemp $tmpdir`
        if ! s3 cp "${file_name}" "${local_file_name}"  --quiet --region "${region}"; then
            error "get_file: Unable to retrieve ${file_name} using $region"
            return 3
        fi
    elif [[ $file_name == http://* ]] || [[ $file_name == https://* ]]; then
        trace "get_file: HTTP/HTTPS"
        local_file_name=`mktemp $tmpdir`
        if ! curl "${file_name}" --output "${local_file_name}" --silent; then
            error "Unable to retrieve ${file_name}"
            return 4
        fi
    else
        trace "get_file: local file"
        local_file_name=$(echo "${file_name}" | awk '{ gsub(/^file:\/\//, ""); print; }')
        if [ ! -f $local_file_name ]; then
            error "File ${local_file_name} does not exist"
            return 5
        fi
    fi
    echo "${local_file_name}"
}


function flatten {
    awk '
        BEGIN {found=-1;}
        /\{/ {
            found=found+1; 
            line[found]=""; 
            next;
        }
        /\}/ {
            print line[found];
            found=found-1;
            next;
        }
        {
            if (found > -1) {
                gsub(/^[ \t]*/, "", $0); 
                gsub(/[ \t]*$/, "", $0); 
                line[found]=line[found]$0
            } 
        }'
}

function reverse {
    tac
}


function get_field {
    local name="$1"
    local pattern="${2:-.*}"
    local value=`awk -F "," -v name="${name}" -v pattern="${pattern}" ' 
        function fix(value) {
            gsub(/^[ ]*\"/, "", value);
            gsub(/\"$/, "", value);
            return value;
        }
        { 
            for (i = 1; i <= NF; i++) {
                n = index($i, ":")
                field_name= fix(substr($i, 1, n-1))
                if (name == field_name) {
                    field_value = fix(substr($i, n+1))
                    if (match(field_value, pattern)) {
                        print field_value;
                    }
                }
            }
        }'`
    echo -e "${value}"
}

function convert_dos2unix {
    yum -y install dos2unix
    for file in $*;  do
        log "Convert ${file} from DOS to Unix"
        dos2unix --quiet "${file}" --keepdate
    done
}


# =============================================================================
#  AWS (related) functions
# =============================================================================

function get_aws_profile {
    local profile="${AWS_PROFILE}"
    # if [ "${profile}" == "" ];  then
    #     profile="default"
    #     # Make next call faster
    #     AWS_PROFILE="${profile}"
    # fi
    echo "${profile}"
}

function get_aws_region {
    local region="${AWS_REGION}" profile
    if [ "${region}" == "" ];  then
        profile=$(get_aws_profile)
        if [ "${profile}" != "" ]; then
            region=$(aws configure get region --profile $profile)
            # Make subsequent calls faster
            AWS_REGION="${region}"
        fi
    fi
    echo "${region}"
}

function do_aws {
    local profile=$(get_aws_profile)
    local region=$(get_aws_region)
    local aws_command args=""
    while test $# -gt 0; do
        case $1 in
          -r|--region)   shift; region="$1" ;;
          *)             args="${args} $1"
        esac
        shift
    done
    if [ "${profile}" != "" ]; then
        args="${args} --profile ${profile}"
    fi
    if [ "${region}" != "" ]; then
        args="${args} --region ${region}"
    fi
    aws_command="aws ${args}"
    trace "About to do [${aws_command}]"
    $aws_command 2>&1
}

function s3 {
    do_aws s3 $*
}

function s3api {
    do_aws s3api $* $region_arg
}

function cloudformation {
    do_aws cloudformation $*
}

function ec2 {
      do_aws ec2 $*
}

function create_resource_tag {
    local key="$1"
    local value="$2"
    local tag='{"Key":"'"${key}"'","Value":"'"${value}"'"}'
    extra_verbose "created tag [${tag}]"
    echo -e "${tag}"
}

function s3_bucket_exists {
    local name="$1"
    local exists=$(s3api list-buckets --query "Buckets[?Name=='${name}'].{Name:Name}")
    trace "list-buckets(${name}) => ${exists}"
    if [ "${exists}" != "${name}" ]; then
        return 0
    fi
    trace "head-bucket: ${exists}"
    return 1
}

function create_s3_bucket {
    local name="$1"
    s3api create-bucket --bucket "${name}"
}

# Grantee is a group name: AuthenticatedUsers, AllUsers, Owner
# Right is string: read, write, read-acp,write-acp, full-control
function set_s3_bucket_acl {
    local bucket="$1"
    local grantee="$2"
    local rights="$3"
    local granteeURI="uri=\"http://acs.amazonaws.com/groups/global/${grantee}\""
    local ownerID=`s3api get-bucket-acl --bucket "${bucket}" \
        --output 'text' | awk -F "\t" '/OWNER/ {section=1; print $3;}'`
    local acl="--grant-full-control id=\"${ownerID}\""
    for right in ${rights};  do
        acl="${acl} --grant-${right} ${granteeURI}"
    done
    writeln "Granting '${grantee}':${rights}, 'OWNER=${ownerID}':full-control"
    s3api put-bucket-acl --bucket "${bucket}" ${acl} # > /dev/null
}

function sync_s3_bucket {
    local name="$1"
    local source_dir="$2"
    local region_arg=""
    if ! $(s3_bucket_exists "${name}"); then
        error "Cannot sync bucket ${name} from source directory ${source_dir},"\
            "because bucket does not exist"
        return 1
    elif [ ! -d "${source_dir}" ]; then
        error "Cannot sync bucket ${name} from source directory ${source_dir},"\
            "because directory does not exist"
        return 2
    fi
    if [ "${BUCKET_REGION}" != "" ]; then
        region_arg="--region ${BUCKET_REGION}"
    fi

    s3 sync "${source_dir}" "s3://${BUCKET_NAME}" ${region_arg} || return 3
}


function create_s3_url {
    local path bucket region url
    while test $# -gt 0; do
        case $1 in
          -b|--bucket)   shift; bucket="$1"  ;;
          -r|--region)   shift;; #region="$1" ;;
          -p|--path)     shift; path="$1" ;;
          *)             error "create_s3_url: Unknown argument '$1'" return 1;;
        esac
        shift
    done
    # if [ "${region}" == "" ]; then
    #     region=$(get_aws_region)
    # fi
    case $region in
        ""|"us-east-1")    region="" ;;
        *)                 region="-${region}" ;;
    esac
    if [ "${path}" != "" ]; then
        path="/${path}"
    fi
    url="https://s3${region}.amazonaws.com/${bucket}${path}"
    trace "S3-url=[${url}]"
    echo "${url}"
}



function validate_cf_template {
    local template bucket tmpfile=$(mktemp) region url result error
    while test $# -gt 0; do
        case $1 in
          -b|--bucket)      shift; bucket="$1" ;;
          -r|--region)      shift; region="$1";;
          -t|--template)    shift; template="$1" ;;
          *)                if [ "${template}" == "" ]; then template="$1"
                            elif [ "${bucket}" == "" ]; then bucket="$1"
                            else 
                                error "validate_cf_template: Unknown argument '$1'"
                                return 1
                            fi
                            ;;
        esac
        shift
    done
    if [ "${bucket}" == "" ];  then
        verbose "Validating local template '${template}'"
        cloudformation validate-template --template-body "file://${template}" 2> ${tmpfile} \
            1> /dev/null
    else
        verbose "Validating template '${template}' in bucket '${bucket}'"
        url=`create_s3_url --bucket "${bucket}" --path "${template}"`
        cloudformation validate-template --template-url "${url}" 2> ${tmpfile} 1> /dev/null
    fi
    result=`cat ${tmpfile}`
    trace "result=${result}"
    error=`echo -e ${result} | grep "ValidationError"`
    rm -f "${tmpfile}"
    if [ "${error}" != "" ]; then
        error "The following problem occurred in template ${template}:[${result}]"
        return 2
    else 
        extra_verbose "Template ${template} is valid"
    fi
    return 0
}

function get_cf_stackid {
    local name="$1" stack_id result=1
    local filter="[?StackName=='${name}'&&StackStatus!='DELETE_COMPLETE']"
    trace "cf_stack_exists.filter=${filter}"
    cloudformation list-stacks --query "StackSummaries${filter}.{StackId:StackId}" \
        --output text
}

function cf_stack_exists {
    local name="$1" stack_id result=1
    local filter="[?StackName=='${name}'&&StackStatus!='DELETE_COMPLETE']"
    trace "cf_stack_exists.filter=${filter}"
    stack_id=`cloudformation list-stacks --query "StackSummaries${filter}.{StackId:StackId}" \
        --output text`
    if [ "${stack_id}" != "" ]; then result=0; fi
    trace "cf_stack_exists[$name]=${stack_id} yields ${result}"
    return $result
}

function delete_cf_stack {
    local stack="$1" wait_for_completion="$2"
    writeln "Deleting stack ${stack}"
    cloudformation delete-stack --stack "${stack}"
    if [ "${wait_for_completion}" != "" ]; then
        wait_cf_stack "${stack}" "delete" || return 1
    fi
}

function apply_cf_stack {
    local stack bucket region template policy="default-stack-policy.json" parameters
    local template_path template_url policy_url allow_update stack_args
    local output status errorStatus
    STACK_ACTION="create" 
    while test $# -gt 0; do
        case $1 in
          -b|--bucket)        shift; bucket="$1" ;;
          -l|--policy)        shift; policy="$1" ;;
          -p|--parameters)    shift; parameters="$1" ;;
          -r|--region)        shift; region="$1";;
          -t|--template)      shift; template="$1" ;;
          -s|--stack)         shift; stack="$1" ;;
          -a|--allow-update)  shift; allow_update="true" ;;
          *)                  error "create_cf_stack: Unknown argument '$1'"; return 1 ;;
        esac
        shift
    done
    if cf_stack_exists "${STACK_NAME}"; then
        if [ "${allow_update}" == "" ]; then
            error "Stack ${stack} already exists, but not alowed to update"
            return 2;
        fi
        STACK_ACTION="update"
    else 
        stack_args="--disable-rollback"
    fi

    if [ "${stack}" == "" ]; then error "No stack name provided (--stack)"; return 3; fi
    if [ "${bucket}" == "" ]; then error "No bucket provided (--bucket)"; return 4; fi
    if [ "${template}" == "" ]; then error "No template provided (--template)"; return 5; fi
    if [ "${region}" == "" ]; then region=`get_aws_region`; fi
    base_url=`create_s3_url --bucket "${bucket}" --region "${region}"`
    template_path="${template}"
    template_url="${base_url}/${STACK_PATH}/${template_path}"
    policy_url="${base_url}/${STACK_PATH}/${policy}"
    writeln "About to ${STACK_ACTION} stack ${stack} with url '${template_url}'" \
        " and policy '${policy_url}'"
    trace "stack-paramaters=|${parameters}|"
    validate_cf_template --bucket "${bucket}" --template "${STACK_PATH}/${template_path}" || \
        ( error "Validation failed"; return 6)
    output=`cloudformation ${STACK_ACTION}-stack --stack-name "${stack}" \
        --template-url "${template_url}" ${stack_args} --capabilities "CAPABILITY_IAM" \
        --stack-policy-url "${policy_url}" --parameters "${parameters}" \
        --output text || return 6`
    trace "output=${output}"
    status=$(echo -e "${output}" | grep "ValidationError")
    if [ "${status}" != "" ]; then
        errorStatus=$(echo -e "${status}" | grep "No updates are to be performed.")
        if [ "${errorStatus}" == "" ]; then
            error "${output}"
            return 7
        else
            # Not an error, but have to lookup the stack id
            STACK_ID=$(get_cf_stackid "${STACK_NAME}")
            writeln "There were no updates to perform"
        fi
    else 
        STACK_ID="${output}"
    fi
    extra_verbose "Completed ${STACK_ACTION} stack ${STACK_NAME} (StackID: ${STACK_ID})"
}

function update_cf_stack {
    apply_cf_stack $@
}

function create_cf_stack {
    apply_cf_stack $@
}

function cf_stack_action_completed {
    local name="$1"
    local action=$(toupper "$2")
    local status result=1
    local filters=()
    local filter

    filters+=("StackName=='${name}'")
    filters+=("starts_with(StackStatus,'${action}')")
    filters+=("ends_with(StackStatus,'IN_PROGRESS')")
    filter="[?"$(join_by "&&" ${filters[@]})"]"
    trace "cf_stack_action_completed .filter=${filter}"
    status=`cloudformation list-stacks --query "StackSummaries${filter}.{Status:StackStatus}" \
        --output text`
    if [ "${status}" == "" ]; then 
        result=0
    else 
        debug "${action} stack ${name} status is ${status}"
    fi
    trace "cf_stack_action_completed.result=${result}"
    return $result
}

function wait_cf_stack {
    local name="$1"
    local action="$2"
    local max_wait_mins="${3:-60}"
    local polling_secs="${4:-10}"
    local max_wait_secs=$((max_wait_mins * 60))
    local n=$((max_wait_secs / polling_secs))
    local r=$((max_wait_secs % polling_secs))
    local status i=0 elapsed=0
    trace "max_wait_mins=${max_wait_mins}; max_wait_secs=${max_wait_secs}; n=${n}; r=${r};" \
        "polling_secs=${polling_secs}"
    if [ "${r}" -gt 0 ]; then
        n=$((n+1))
    fi
    until [ "${i}" -eq "${n}" ]; do
        writeln "Wait for ${action} stack ${name} to complete ... (${elapsed}s elapsed)"
        if cf_stack_action_completed "${name}" "${action}"; then
            show_cf_stack_status "${name}" "${action}" || return 1
            return 0
        fi
        trace "${action} stack ${name} did not complete yet, " \
            "wait ${polling_secs} seconds"
        sleep $polling_secs
        (( i = i + 1 ))
        (( elapsed = i * polling_secs ))
    done
    writeln "${action} stack ${name} did not complete yet, " \
        "but wait timed out (${elapsed}s elapsed)"
    return 1
}


function show_cf_stack_status {
    local name="$1"
    local action="$2"
    local action_upper=$(toupper "${action}")
    local filter="[?StackName=='${name}']"
    local attributes="Name:StackName,Status:StackStatus,Reason:StackStatusReason"
    local details status reason
    local query="sort_by(Stacks,&CreationTime)${filter}.{${attributes}}"
    trace "get_cf_stack_status query=${query}"

    if ! cf_stack_exists "${name}"; then
        if [ "${action}" == "delete" ]; then
            writeln "${action} ${name} completed"
            return 0
        fi
        warning "Stack ${name} does not exist"
        return 1
    fi
    details=`cloudformation describe-stacks --query "${query}" | flatten | tail -1`
    debug "get_cf_stack_status[${name}] yields ${details}"
    status=$(echo "${details}" | get_field "Status")
    trace "Action=${action_upper} Status = ${status}"
    if [ "${status}" == "${action_upper}_COMPLETE" ]; then
        writeln "${action} ${name} completed"
    else
        reason=$(echo "${details}" | get_field "Reason")
        writeln "${action} ${name} (${status}) failed, because ${reason}:"
        attributes="ResourceId:LogicalResourceId"
        attributes="${attributes},ResourceType:ResourceType"
        attributes="${attributes},Reason:ResourceStatusReason"
        query="StackEvents[?ResourceStatus=='${action_upper}_FAILED'].{${attributes}}"
        details=`cloudformation describe-stack-events --stack-name "${name}" --query "${query}"`
        writeln "${details}"
    fi
}




DEFAULT_AWS_REGION="us-east-1"
DEFAULT_AWS_PROFILE="default"
DEFAULT_MASTER_TEMPLATE="main.json"
DEFAULT_STACK_POLICY="default-stack-policy.json"
DEFAULT_SOURCE_DIRS="."
DEFAULT_TARGET_DIR="./target"
DEFAULT_PATTERN="s|__DELETION_POLICY__|Retain|g"

function set_action {
    local action=$1
    trace "About to set action to '${action}'"
    ACTION=""
    case $action in
        $ACTION_CREATE|$ACTION_DELETE|$ACTION_VERIFY)
                trace "Action set to '${action}'"
                ACTION="${action}" 
                ;;
        *)      error "Unknown argument '$action'"
                return 1
                ;;
    esac
}

function set_argument {
    if [ "${STACK_NAME}" == "" ]; then
        debug "STACK_NAME=$1"
        STACK_NAME="$1"
    elif [ "${ENVIRONMENT}" == "" ]; then
        debug "ENVIRONMENT=$1"
        ENVIRONMENT="$1"
    else 
        error "Unknown argument '$1'"
        return 1
    fi
}

function get_parameters {
    while test $# -gt 0; do
        trace "Checking $1 (next: $2)"
        case $1 in
          -h|--help)                   usage; exit 0 ;;
          -a|--action)                 shift; set_action "$1" ;;
          -b|--bucket)                 shift; BUCKET_NAME=$1 ;;
          -br|--bucket-region)         shift; BUCKET_REGION=$1 ;;
          -c|--security-context)       shift; SECURITY_CONTEXT=$1 ;;
          -f|--config-file)            shift; CONFIG_FILE=$1 ;;
          -i|--input)                  shift; STACK_INPUTS+=("$1") ;;
          -n|--no-cleanup)             CLEANUP="" ;;
          -p|--profile)                shift; AWS_PROFILE=$1 ;;
          -r|--region)                 shift; AWS_REGION=$1 ;;
          -s|--source-dir)             shift; SOURCE_DIRS="${SOURCE_DIRS} $1" ;;
          -t|--target-dir)             shift; TARGET_DIR="$1" ;;
          -v|--verbose)                set_verbose ;;
          -w|--wait-for-completion)    shift; WAIT_FOR_COMPLETION="$1" ;;
          *)                           set_argument "$1" || return 1 ;;
        esac
        shift
    done
}

function get_stack_templates {
    local prefix=$(create_property_name "stack" "templates")
    local names=$(get_property_names "${prefix}" "${CONFIG_DATA}")
    local templates=()
    trace "Checking ${prefix} ${names}"
    for name in $names ; do
        templates+=("${name}")
        extra_verbose "Using template ${name}"
    done
    extra_verbose "Using master template ${MASTER_TEMPLATE}"
    templates+=("${MASTER_TEMPLATE}")
    echo -e "${templates[@]}"
}

# -----------------------------------------------------------------------------
# Renames properties in input files to the correct stack parameter name,
# as it may not always ebe possible to match these (exactly)
# -----------------------------------------------------------------------------
function apply_input_parameter_mapping {
    local input="$1"
    local property=$(create_property_name "stack" "input-mapping")
    local mapping=$(get_property_names "${property}" "${CONFIG_DATA}")
    local patterns=() input_property stack_parameter
    trace "Mapping=${mapping}"
    for input_property in $mapping ; do
        stack_parameter=$(get_property $(create_property_name "${property}" \
            "${input_property}")  "${CONFIG_DATA}")
        extra_verbose "Renaming input property '${input_property}'" \
            "to stack parameter '${stack_parameter}'"
        patterns+=("-e s|^${input_property}|${stack_parameter}|g")
    done
    if [ "${#patterns[@]}" == "0" ]; then
        # No properties to map
        echo -e "${input}"
    else
        trace "Apply patterns: ${patterns[@]}"
        echo -e "${input}" | sed ${patterns[@]}
    fi
}

# -----------------------------------------------------------------------------
# Renames properties in input files to the correct stack parameter name,
# as it may not always ebe possible to match these (exactly)
# -----------------------------------------------------------------------------
function remove_ignored_nput_parameters {
    local input="$1"
    local property=$(create_property_name "stack" "ignored-input")
    local ignored=$(get_property_names "${property}" "${CONFIG_DATA}")
    local patterns=() ignored_property
    trace "ignored=${ignored}"
    for ignored_property in $ignored ; do
        extra_verbose "Ignoring input property '${ignored_property}'"
        patterns+=("-e /^${ignored_property}=.*$/d")
    done
    if [ "${#patterns[@]}" == "0" ]; then
        # No properties to map
        echo -e "${input}"
    else
        trace "Apply patterns: ${patterns[@]}"
        echo -e "${input}" | sed ${patterns[@]}
    fi
}

# -----------------------------------------------------------------------------
# Replace occurrences of __variable__ with the value of the "variable" 
# environment variable.
# E.g. if value is __BUKCET_NAME__, it is replaced with the value of the
# BUCKET_NAME environment variable
# -----------------------------------------------------------------------------
function apply_environment_variables_mapping {
    local value="$1"
    local variable=$(echo "${value}" | sed "s|__\(.*\)__|\1|g")
    local has_variable
    if [ "${variable}" != "" ]; then
        has_variable=$(echo "${value}" | grep "__${variable}__")
        if [ "${has_variable}" != "" ]; then
            extra_verbose "Replace __${variable}__ with ${!variable}"
            value=$(echo "${value}" | sed "s|__${variable}__|${!variable}|g")
        else
            trace "Variable ${variable} not found in ${value}"
        fi
    fi
    echo "${value}"
}


# -----------------------------------------------------------------------------
# Converts properties in input files:
#    1. Converts tfvars files to properties file format
#    2. Map input property names to stack parameters as specified
#       in the configuration file (default: stack.yml) property
#       'stack.input-mapping'. E.g. 
#           stack:
#              input-mapping:
#                   my-vpc-id: VPCID
#       The above example maps the 'my-vpc-id' property to 
#       the 'VPCID' stackj parameter
# -----------------------------------------------------------------------------
function convert_input_parameters {
    local input_file="$1"
    local prefix="$2"
    local property=$(create_property_name --prefix "${prefix}")
    local input
    trace "Convert from Terraform output to properties file"
    input=$(cat "${input_file}" | sed -e "/^#/d" -e 's| = |=|g' -e 's|"||g')
    trace "Remove ignored input properties as parameters"
    input=$(remove_ignored_nput_parameters "${input}")
    trace "Map input property names to expected parameter stack names"
    input=$(apply_input_parameter_mapping "${input}")
    trace "Insert parameter property prefix (${property})"
    echo -e "${input}" | sed -e "s|^|${property}|g"
}

function get_stack_parameters {
    local prefix=$(create_property_name "stack" "parameters")
    local parameters=() value variable input_file input_files="${STACK_INPUTS[@]}"
    local name names region_arg
    local property=$(create_property_name --prefix "${prefix}")
    local region_arg
    if [ "${BUCKET_REGION}" != "" ]; then
        region_arg="--region ${BUCKET_REGION}"; 
    fi
    for input_file in $input_files ; do
        verbose "Adding input from '${input_file}'"
        if ! input_file=$(get_file "${input_file}" $region_arg); then
            return 1
        fi
        if [ -f ${input_file} ]; then
            input=$(convert_input_parameters "${input_file}" "${prefix}")
            # input=$(cat "${input}" | sed -e "/^#/d" -e 's| = |=|g' \
            #     -e 's|"||g' -e "s|^|${property}|g" )
            trace "Adding [\n${input}\n] to CONFIG_DATA]"
            CONFIG_DATA=$(echo -e "${CONFIG_DATA}\n${input}")
        else
            warning "Input file ${input} not found"
        fi
    done
    trace "CONFIG_DATA=${CONFIG_DATA}"
    names=$(get_property_names "${prefix}" "${CONFIG_DATA}")
    trace "Checking parameters: ${names}"
    for name in $names ; do
        property=$(create_property_name "${prefix}" "${name}")
        value=$(apply_environment_variables_mapping \
            $(get_property "${property}" "${CONFIG_DATA}"))
        # variable=$(echo "${value}" | sed "s|__\(.*\)__|\1|g")
        # if [ "${variable}" != "" ]; then
        #     # Replace occurrences of __variable__ with
        #     # the value of "variable" environment variable
        #     # E.g. if value is __BUKCET_NAME__, it is replaced 
        #     # with the value of the BUCKET_NAME environment variable
        #     trace "Replace __${variable}__ with ${!variable}"
        #     value=$(echo "${value}" | sed "s|__${variable}__|${!variable}|g")
        # fi
        parameters+=("${name}=${value}")
        extra_verbose "Using stack parameter" \
            $(get_property_name_without_context ${name}) \
            "= ${value}"
    done
    echo -e "${parameters[@]}"
}

function get_stack_property {
    local name=$(create_property_name "stack" "$1")
    local override_value="$2"
    local default_value="$3"
    local value value_source
    if [ "${override_value}" != "" ]; then
        value="${override_value}"
        value_source="command-line"
    else
        value=$(get_property "${name}" "${CONFIG_DATA}")
        value_source="config-file"
    fi
    if [ "${value}" == "" ]; then
        value="${default_value}"
        if [ "${value}" != "" ]; then
            value_source="default"
        fi
    fi
    extra_verbose "Using property" \
        $(get_property_name_without_context ${name}) \
        "= ${value} (source: ${value_source})"
    echo -e "${value}"
}

function get_stack_scripts {
    local prefix=$(create_property_name "stack" "scripts")
    local names=$(get_property_names "${prefix}" "${CONFIG_DATA}")
    local scripts=() value
    trace "Checking scripts ${names} (${prefix})"
    for name in $names ; do
        parameters+=("${name}")
        extra_verbose "Using script ${name}"
    done
    echo -e "${parameters[@]}"
}

function get_stack_script_source {
    local name="$1"
    local prefix=$(create_property_name "stack" "scripts" \
        "${name}" "source")
    get_property "${prefix}" "${CONFIG_DATA}"
}

function get_stack_security_context {
    if [ "${SECURITY_CONTEXT}" == "" ]; then 
        case $ENVIRONMENT in
            dev-*)      SECURITY_CONTEXT="dev" ;;
            *)          SECURITY_CONTEXT="${ENVIRONMENT}" ;;
        esac
    fi
    trace "Using SecurityContext=${SECURITY_CONTEXT}"
}

function create_stack_name {
    echo "${SYSTEM_NAME}-${ENVIRONMENT}-${STACK_NAME}" |\
        sed -e 's|[_/.]|-|g' \
            -e 's|[!@#\$%&*+()?<>]||g'
}

function add_default_inputs {
    local source_dir
    for source_dir in $SOURCE_DIRS; do
        if [ -f "${source_dir}/input.tfvars" ]; then
            verbose "Adding input file '${source_dir}/input.tfvars'"
            inputs+=("${source_dir}/input.tfvars")
        fi
    done
}

function set_config_data {
    local source_dir region_arg
    if [ "${CONFIG_FILE}" == "" ]; then
        for source_dir in $SOURCE_DIRS; do
            if [ -f "${source_dir}/stack.yml" ]; then
                CONFIG_FILE="${source_dir}/stack.yml"
                verbose "Using config file '${CONFIG_FILE}'"
                break
            fi
        done
    fi
    if [ "${CONFIG_FILE}" == "" ]; then
        error "No configuration file provided."
        return 1
    fi
    if [[ $CONFIG_FILE == s3://* ]]; then
        region_arg="--region ${AWS_REGION}"
    fi
    CONFIG_DATA=$(get_config_data $region_arg "${CONFIG_FILE}")
}

function verify_variable {
    local name="$1"
    local description="${2:-$$name}"
    if [ "$$name" == "" ]; then
        error "No ${description} provided."
        return 1 
    fi
    trace "Using ${name}=$${name}"
}

function add_default_stack_inputs {
    local source_dir input_file input_files
    for source_dir in $SOURCE_DIRS; do
        extra_verbose "Checking for default inputs in ${source_dir}"
        input_files=$(find "${source_dir}" -iregex ".*\.\(tfvars\)" -printf "%f")
        for input_file in $input_files; do
            extra_verbose "Adding stack input ${source_dir}/${input_file}"
            STACK_INPUTS+=("${source_dir}/${input_file}")
        done
    done
}

function initialize {
    SOURCE_DIRS="${SOURCE_DIRS} ${SCRIPT_DIR}"
    get_parameters "$@" || return 1
    if [ "${SOURCE_DIRS}" == "" ]; then SOURCE_DIRS="${DEFAULT_SOURCE_DIRS}"; fi
    if [ "${TARGET_DIR}" == "" ]; then TARGET_DIR="${DEFAULT_TARGET_DIR}"; fi
    verify_variable "ENVIRONMENT" "environment" || return 1
    get_stack_security_context
    add_default_inputs || return 2
    set_config_data || return 3
    trace "CONFIG_DATA=[\n${CONFIG_DATA}\n]"
    AWS_PROFILE=$(get_stack_property aws_profile "${AWS_PROFILE}")
    AWS_REGION=$(get_stack_property aws_region "${AWS_REGION}"  "${DEFAULT_AWS_REGION}")
    BUCKET_NAME=$(get_stack_property bucket_name "${BUCKET_NAME}")
    STACK_NAME=$(get_stack_property name "${STACK_NAME}")
    SYSTEM_NAME=$(get_stack_property $(create_property_name "parameters" "System") "datagov")
    STACK_PATH="cloud-formation/${SYSTEM_NAME}/${ENVIRONMENT}/${STACK_NAME}"
    MASTER_TEMPLATE=$(get_stack_property "master_template" "" "${DEFAULT_MASTER_TEMPLATE}")
    STACK_POLICY=$(get_stack_property policy "" "${DEFAULT_STACK_POLICY}")
    STACK_TEMPLATES=$(get_stack_templates)
    add_default_stack_inputs
    STACK_PARAMETERS=`get_stack_parameters || return 10`
    STACK_SCRIPTS=$(get_stack_scripts)

    if [ "${STACK_NAME}" == "" ]; then error "No stack name provided."; return 4; fi
    if [ "${BUCKET_NAME}" == "" ]; then error "No bucket name provided."; return 5; fi
    STACK_NAME=$(create_stack_name)

    verbose "Using:"
    verbose "\tStack=${STACK_NAME}"
    verbose "\tBucket=${BUCKET_NAME}"
    verbose "\tPath=${STACK_PATH}"
    verbose "\tSources=${SOURCE_DIRS}"
    verbose "\tInputs=${STACK_INPUTS[@]}"
    verbose "\tTarget=${TARGET_DIR}"
}




TEMPLATES_PATH="templates"
POLICIES_PATH="policies"
SCRIPTS_PATH="scripts"

function cleanup {
    local override="$1"
    if [ "${override}" != "" ] || [ "${CLEANUP}" != "" ]; then
        rm -rf "${TARGET_DIR}"
    fi
}


function compile_templates {
    local t template path source_dir template_target
    extra_verbose "Compiling templates: ${STACK_TEMPLATES}"
    for t in $STACK_TEMPLATES; do
        template=""
        for path in "${t}" "${TEMPLATES_PATH}/${t}"; do
            for source_dir in $SOURCE_DIRS; do
                verbose "Looking for template ${t} in ${source_dir}/${path}"
                template="${source_dir}/${path}"
                if [ -f "${template}" ]; then
                    writeln "Using template ${template}"
                    template_target="${TARGET_DIR}/${STACK_PATH}/${path}"
                    mkdir -p $(dirname "${template_target}")
                    cp -f "${template}" "${template_target}"
                    validate_cf_template "${template_target}" || return 2
                    break 2
                else
                    template=""
                    extra_verbose "Template ${path} not found in ${source_dir}/"
                fi
            done
        done
        if [ "${template}" == "" ]; then
            error "Could not find template '${path}' anywhere in ${SOURCE_DIRS}"
            return 2
        fi
    done
}

function compile_policy {
    local policy path source_dir policy_path
    extra_verbose "Compiling policy: ${STACK_POLICY}"
    for path in "${STACK_POLICY}" "${POLICIES_PATH}/${STACK_POLICY}"; do
        for source_dir in $SOURCE_DIRS; do
            policy="${source_dir}/${path}"
            if [ -f "${policy}" ]; then
                policy_path="${path}"
                mkdir -p $(dirname "${TARGET_DIR}/${STACK_PATH}/${path}")
                writeln "Using policy ${policy}"
                cp -f "${policy}" "${TARGET_DIR}/${STACK_PATH}/${path}"
                break 2
            else
                policy=""
                policy_path=""
            fi
        done
    done
    if [ "${policy}" == "" ]; then
        error "Could not find policy '${path}' anywhere in ${SOURCE_DIRS}"
        return 2
    fi
    extra_verbose "Stack policy: ${policy_path}"
    STACK_POLICY="${policy_path}"
}

function compile_scripts {
    local i script path source_dir
    extra_verbose "Compiling scripts: ${STACK_SCRIPTS}"
    for i in $STACK_SCRIPTS; do
        script=""
        for path in "${i}" "${SCRIPTS_PATH}/${i}"; do
            for source_dir in $SOURCE_DIRS; do
                script="${source_dir}/${path}"
                debug "Checking if script ${i} exists in ${script}"
                if [ -f "${script}" ]; then
                    writeln "Using script ${script}"
                    mkdir -p $(dirname "${TARGET_DIR}/${STACK_PATH}/${path}")
                    cp -f "${script}" "${TARGET_DIR}/${STACK_PATH}/${path}"
                    break 2
                else
                    script=""
                    debug "Script ${path} not found in ${src_dir}/"
                fi
            done
        done
        if [ "${script}" == "" ]; then
            error "Could not find script '${path} anywhere in ${SOURCE_DIRS}"
            return 2
        fi
    done
}
function compile_stack {
    writeln "Building stack ${STACK_NAME} in ${TARGET_DIR}"
    cleanup "true" || return 1
    compile_templates || return 2
    compile_policy || return 3
    compile_scripts  || return 4
}

# function create_bucket {
#     local grantees="AuthenticatedUsers"
#     local permissions="read write read-acp write-acp"
#     if ! $(s3_bucket_exists "${BUCKET_NAME}"); then
#         create_s3_bucket "${BUCKET_NAME}" || return 1
#         set_s3_bucket_acl "${BUCKET_NAME}" "${grantees}" "${permissions}" | return 2
#     fi
# }

function sync_bucket {
    sync_s3_bucket "${BUCKET_NAME}" "${TARGET_DIR}" || (error "Sync failed"; return 1 )
}

function create_stack_parameters {
    local parameters="${STACK_PARAMETERS}" name value i=1
    local cf_parameters=""

    for parameter in $parameters; do
        name=$(get_property_name "${parameter}")
        value=$(get_property "${name}" "${parameter}")
        if [ "${i}" -gt 1 ]; then 
            cf_parameters="${cf_parameters} "
        fi
        cf_parameters="${cf_parameters}ParameterKey=${name}"
        cf_parameters="${cf_parameters},ParameterValue=${value}"
        cf_parameters="${cf_parameters},UsePreviousValue=false"
        trace "Using stack parameter ${name}=[${value}]"
        ((i++))
    done
    cf_parameters="${cf_parameters}"
    trace "stack-parameters=${cf_parameters}"
    echo -e "${cf_parameters}"
}

function create_stack {
    local parameters=$(create_stack_parameters)
    apply_cf_stack --stack "${STACK_NAME}" --bucket "${BUCKET_NAME}" \
        --template ${MASTER_TEMPLATE} --policy "${STACK_POLICY}" \
        --parameters "${parameters}" --allow-update || return 1
}

function delete_stack {
    if ! cf_stack_exists "${STACK_NAME}"; then
        warning "Nothing to do. Stack ${STACK_NAME} does not exist"
    else 
        delete_cf_stack "${STACK_NAME}" "wait-for-completion"
    fi
}

function instance_passes_healthcheck {
    local resource="$1" status
    # Find the instance
    local instanceID=$(ec2 describe-instances \
            --filter "Name=tag:aws:cloudformation:stack-id,Values=${STACK_ID}" \
                     "Name=tag:aws:cloudformation:logical-id,Values=${resource}" \
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
    local prefix=$(create_property_name "stack" "wait" "conditions")
    RESOURCES_READY=""
    for name in $conditions ; do
        condition=$(get_property $(create_property_name "${prefix}" \
            "${name}") "${CONFIG_DATA}")
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

function wait_for_resources_completion {
    local delay max_iterations i=0 resources
    local default_delay=15 default_iterations elapsed=0
    local prefix=$(create_property_name "stack" "wait")
    if [ "${CONFIG_DATA}" == "" ]; then
        return 0
    fi
    resources=$(get_property_names $(create_property_name "${prefix}" \
        "conditions") "${CONFIG_DATA}")
    if [ "${resources}" == "" ]; then
        writeln "No resources to wait for found in stack.yml"
        return 0
    fi
    extra_verbose "Waiting for [${resources}] to complete"
    # delay in seconds
    delay=$(get_property $(create_property_name "${prefix}" "delay") \
        "${CONFIG_DATA}" "30")
    # default is 2 hours 
    (( default_iterations = 2 * 60 * 60 / $delay ))
    max_iterations=$(get_property $(create_property_name "${prefix}" \
        "max-iterations") "${CONFIG_DATA}" "${default_iterations}")
    debug "i=$i; max_iterations=$max_iterations"
    while [ "${i}" -lt "${max_iterations}" ] &&
          ! all_resources_completed "${elapsed}" "${resources}";
    do
        sleep "${delay}"
        (( i += 1 ))
        (( elapsed = i * delay ))
    done
}

function wait_for_completion {
    if [ "${WAIT_FOR_COMPLETION}" != "" ]; then
        wait_cf_stack "${STACK_NAME}" "${STACK_ACTION}" "${WAIT_FOR_COMPLETION}" \
            || return 1
        wait_for_resources_completion || return 2
    fi
}


# ================================================================================
#   MAIN
# ================================================================================

initialize "$@" || exit 1
if [ "${ACTION}" != "${ACTION_DELETE}" ]; then
    compile_stack || exit 2
fi
if [ "${ACTION}" == "${ACTION_CREATE}" ]; then
    sync_bucket || exit 3
    create_stack || exit 4
elif [ "${ACTION}" == "${ACTION_DELETE}" ]; then
    delete_stack || exit 5
fi
if [ "${ACTION}" == "${ACTION_CREATE}" ]; then
    wait_for_completion || exit 6
fi
cleanup

