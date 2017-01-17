#!/bin/sh

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR=$(dirname $0)

ACTION_CREATE="create"
ACTION_DELETE="delete"
ACTION_VERIFY="verify"
ACTION="${ACTION_CREATE}"
CONFIG_DATA=
CLEANUP="true"
BUCKET_NAME=
MASTER_TEMPLATE=
STACK_POLICY=
STACK_NAME=
STACK_TEMPLATES=
STACK_PARAMETERS=
STACK_PATTERNS=
STACK_INITIALIZERS=
SOURCE_DIRS=""
TARGET_DIR=""
ENVIRONMENT=""
SECURITY_CONTEXT=""
INPUTS=()

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
    local name=""
    for segment in $@; do
        if [ "${name}" != "" ]; then 
            name="${name}${PROPERTIES_FS}"
        fi
        name="${name}${segment}"
    done
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
        if ! aws s3 cp "${file_name}" "${local_file_name}"  --quiet --region "${region}"; then
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
            # Make subsequent calls faster
            AWS_REGION="${region}"
        fi
    fi
    echo "${region}"
}

function do_aws {
    local profile=$(get_aws_profile)
    local region=$(get_aws_region)
    local aws_command="aws $* --profile ${profile} --region ${region}"
    trace "About to do [${aws_command}]"
    $aws_command 2>&1
}

function s3 {
   do_aws s3 $*
}

function s3api {
   do_aws s3api $*
}

function cloudformation {
      do_aws cloudformation $*
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
    extra_verbose "=====> head-bucket: ${exists} <======="
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
    # if ! $(s3_bucket_exists "${name}"); then
    #     error "Cannot sync bucket ${name} from source directory ${source_dir},"\
    #         "because bucket does not exist"
    #     return 1
    # elif [ ! -d "${source_dir}" ]; then
    #     error "Cannot sync bucket ${name} from source directory ${source_dir},"\
    #         "because directory does not exist"
    #     return 2
    # fi
    s3 sync "${source_dir}" "s3://${BUCKET_NAME}"
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
    fi
    return 0
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
    local stack="$1" wait_for_completion="$2" deleted wait_secs=30
    writeln "Deleting stack ${stack}"
    cloudformation delete-stack --stack "${stack}"
    if [ "${wait_for_completion}" != "" ]; then
        wait_cf_stack "${stack}" "delete" || return 1
    fi
}


function create_cf_stack {
    local stack bucket region template policy="default-stack-policy.json" parameters
    local template_path template_url policy_url
    while test $# -gt 0; do
        case $1 in
          -b|--bucket)      shift; bucket="$1" ;;
          -l|--policy)      shift; policy="$1" ;;
          -p|--parameters)  shift; parameters="$1" ;;
          -r|--region)      shift; region="$1";;
          -t|--template)    shift; template="$1" ;;
          -s|--stack)       shift; stack="$1" ;;
          *)                error "create_cf_stack: Unknown argument '$1'"; return 1 ;;
        esac
        shift
    done
    if [ "${stack}" == "" ]; then error "No stack name provided (--stack)"; return 2; fi
    if [ "${bucket}" == "" ]; then error "No bucket provided (--bucket)"; return 3; fi
    if [ "${template}" == "" ]; then error "No template provided (--template)"; return 4; fi
    if [ "${region}" == "" ]; then region=`get_aws_region`; fi
    base_url=`create_s3_url --bucket "${bucket}" --region "${region}"`
    template_path="${template}"
    template_url="${base_url}/cloud-formation/${template_path}"
    policy_url="${base_url}/cloud-formation/${policy}"
    writeln "About to create stack ${stack} with url '${template_url}' and policy '${policy_url}'"
    trace "stack-paramaters=|${parameters}|"
    validate_cf_template --bucket "${bucket}" --template "cloud-formation/${template_path}" || \
        return 2
    local stack_id=`cloudformation create-stack --stack-name "${stack}" \
        --template-url "${template_url}" --disable-rollback  --capabilities "CAPABILITY_IAM" \
        --stack-policy-url "${policy_url}" --parameters "${parameters}" || return 1`
    writeln "Created stack '${stack_id}'"
}

function update_cf_stack {
    local stack bucket region template policy="default-stack-policy" parameters
    local template_path template_url policy_url
    while test $# -gt 0; do
        case $1 in
          -b|--bucket)      shift; bucket="$1" ;;
          -l|--policy)      shift; policy="$1" ;;
          -p|--parameters)  shift; parameters="$1" ;;
          -r|--region)      shift; region="$1";;
          -t|--template)    shift; template="$1" ;;
          -s|--stack)       shift; stack="$1" ;;
          *)                error "create_cf_stack: Unknown argument '$1'"; return 1 ;;
        esac
        shift
    done
    if [ "${stack}" == "" ]; then error "No stack name provided (--stack)"; return 2; fi
    if [ "${bucket}" == "" ]; then error "No bucket provided (--bucket)"; return 3; fi
    if [ "${template}" == "" ]; then error "No template provided (--template)"; return 4; fi
    if [ "${region}" == "" ]; then region=`get_aws_region`; fi
    base_url=`create_s3_url --bucket "${bucket}"  --region "${region}"`
    template_path="templates/${template}"
    template_url="${base_url}/cloud-formation/${template_path}"
    policy_url="${base_url}/cloud-formGation/${policy}"
    writeln "About to create stack ${stack} with url '${template_url}' and policy '${policy_url}'"
    trace "stack-paramaters=|${parameters}|"
    validate_cf_template --bucket "${bucket}" --template "cloud-formation/${template_path}" || \
        return 2
    local stack_id=`cloudformation update-stack --stack-name "${stack}" \
        --template-url "${template_url}" --capabilities "CAPABILITY_IAM" \
        --stack-policy-url "${policy_url}" --parameters "${parameters}"`
    writeln "Updated stack '${stack_id}'"
}

function cf_stack_action_completed {
    local name="$1"
    local action=$(toupper "$2")
    local stack_id result=1
    local filter="[?StackName=='${name}'&&StackStatus=='${action}_IN_PROGRESS']"
    debug "wait_cf_create_stack.filter=${filter}"
    stack_id=`cloudformation list-stacks --query "StackSummaries${filter}.{StackId:StackId}" \
        --output text`
    if [ "${stack_id}" == "" ]; then result=0; fi
    debug "wait_cf_create_stack[$name]=${stack_id} yields ${result}"
    return $result
}

function wait_cf_stack {
    local name="$1"
    local action="$2"
    local max_wait_mins="${3:-60}"
    local polling_secs="${4:-60}"
    local max_wait_secs=$((max_wait_mins * 60))
    local n=$((max_wait_secs / polling_secs))
    local r=$((max_wait_secs % polling_secs))
    local status i=0
    trace "max_wait_mins=${max_wait_mins}; max_wait_secs=${max_wait_secs}; n=${n}; r=${r};" \
        "polling_secs=${polling_secs}"
    if [ "${r}" -gt 0 ]; then
        n=$((n+1))
    fi
    until [ "${i}" -eq "${n}" ]; do
        i=$((i+1))
        writeln "Wait for ${action} stack ${name} to complete ... (${i} of ${n})"
        if cf_stack_action_completed "${name}" "${action}"; then
            show_cf_stack_status "${name}" "${action}" || return 1
            return 0
        fi
        if [ "${n}" -eq 0 ]; then
            extra_verbose "${action} stack ${name} did not complete yet, but wait timed out"
        else
            extra_verbose "${action} stack ${name} did not complete yet, " \
                "wait ${polling_secs} seconds"
            sleep $polling_secs
        fi
    done
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
    debug "Action=${action_upper} Status = ${status}"
    if [ "${status}" == "${action_upper}_COMPLETE" ]; then
        writeln "${action} ${name} completed"
    else
        reason=$(echo "${details}" | get_field "Reason")
        writeln "${action} ${name} failed, because ${reason}:"
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
          -c|--security-context)       shift; SECURITY_CONTEXT=$1 ;;
          -f|--config-file)            shift; CONFIG_FILE=$1 ;;
          -i|--input)                  shift; INPUTS+=("$1") ;;
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
    local prefix="stack${PROPERTIES_FS}templates"
    local names=$(get_property_names "${prefix}" "${CONFIG_DATA}")
    local templates=()
    trace "Checking ${prefix} ${names}"
    for name in $names ; do
        templates+=("${name}")
        extra_verbose "Using template ${name}"
    done
    extra_verbose "Using master template ${name}"
    templates+=("${MASTER_TEMPLATE}")
    echo -e "${templates[@]}"
}

function get_stack_parameters {
    local prefix="stack${PROPERTIES_FS}parameters"
    local parameters=() value variable input inputs="${INPUTS[@]}"
    for input in $inputs ; do
        verbose "Adding input from '${input}'"
        if [ -f ${input} ]; then
            input=$(cat "${input}" | sed -e "/^#/d" -e 's| = |=|g' \
                -e 's|"||g' -e "s|^|${prefix}${PROPERTIES_FS}|g" )
            trace "Adding [\n${input}\n] to [\n${CONFIG_DATA}\n]"
            CONFIG_DATA=$(echo -e "${CONFIG_DATA}\n${input}")
        else
            warning "Input ${input} not found"
        fi
    done
    trace "CONFIG_DATA=${CONFIG_DATA}"
    names=$(get_property_names "${prefix}" "${CONFIG_DATA}")
    trace "Checking parameters: ${names}"
    for name in $names ; do
        value=$(get_property "${prefix}${PROPERTIES_FS}${name}" "${CONFIG_DATA}")
        variable=$(echo "${value}" | sed "s|__\(.*\)__|\1|g")
        if [ "${variable}" != "" ]; then
            # Replace occurrences of __variable__ with
            # the value of "variable" environment variable
            # E.g. if value is __BUKCET_NAME__, it is replaced 
            # with the value of the BUCKET_NAME environment variable
            value=$(echo "${value}" | sed "s|__${variable}__|${!variable}|g")
        fi
        parameters+=("${name}=${value}")
        extra_verbose "Using parameter ${name}=[${value}]"
    done
    echo -e "${parameters[@]}"
}

function get_stack_patterns {
    local prefix="stack${PROPERTIES_FS}variables"
    local names=$(get_property_names "${prefix}" "${CONFIG_DATA}") value
    local variables=() pattern
    for name in $names ; do
        value=$(get_property "${prefix}${PROPERTIES_FS}${name}" "${CONFIG_DATA}")
        pattern="s|__$(toupper "${name}")__|${value}|g"
        variables+=("${pattern}")
        extra_verbose "Using pattern [${pattern}]"
    done
    variables+=("${DEFAULT_PATTERN}")
    extra_verbose "Using default pattern ["${DEFAULT_PATTERN}"]"
    echo -e "${variables[@]}"
}

function get_stack_property {
    local name="stack${PROPERTIES_FS}$1"
    local override_value="$2"
    local value
    if [ "${override_value}" != "" ]; then
        extra_verbose "Using ${name}=[${value}] (command-line override)"
        value="${override_value}"
    else
        extra_verbose "Using ${name}=[${value}]"
        value=$(get_property "${name}" "${CONFIG_DATA}")
    fi
    echo -e "${value}"
}

function get_stack_initializers {
    local prefix="stack${PROPERTIES_FS}initializers"
    local names=$(get_property_names "${prefix}" "${CONFIG_DATA}")
    local initializers=() value
    trace "Checking initializers ${names}"
    for name in $names ; do
        parameters+=("${name}")
        extra_verbose "Using initializer ${name}"
    done
    echo -e "${parameters[@]}"
}

function get_stack_initializer_source {
    local name="$1"
    local FS="${PROPERTIES_FS}"
    local prefix="stack${FS}initializers${FS}${name}${FS}source"
    get_property "${prefix}" "${CONFIG_DATA}"
}

function get_stack_security_context {
    set -x
    if [ "${SECURITY_CONTEXT}" == "" ]; then 
        case $ENVIRONMENT in
            dev-*)      SECURITY_CONTEXT="dev" ;;
            *)          SECURITY_CONTEXT="${ENVIRONMENT}" ;;
        esac
    fi
    set +x
    verbose "Using SecurityContext=${SECURITY_CONTEXT}"
}

function initialize {
    local region_arg variables p
    SOURCE_DIRS="${SOURCE_DIRS} ${SCRIPT_DIR}"
    get_parameters "$@" || return 1
    if [ "${ENVIRONMENT}" == "" ]; then
        error "No environment provided."
        return 1
    fi
    verbose "Using Environment=${ENVIRONMENT}"
    get_stack_security_context
    if [ "${CONFIG_FILE}" == "" ]; then
        error "No configuration file provided."
        return 2
    fi
    if [[ $file_name == s3://* ]]; then
        region_arg="--region ${AWS_REGION}"
    fi
    CONFIG_DATA=`get_config_data $region_arg "${CONFIG_FILE}"`
    AWS_PROFILE=$(get_stack_property aws_profile "${AWS_PROFILE}")
    AWS_REGION=$(get_stack_property aws_region "${AWS_REGION}")
    BUCKET_NAME=$(get_stack_property bucket_name "${BUCKET_NAME}")
    STACK_NAME=$(get_stack_property name)
    MASTER_TEMPLATE=$(get_stack_property master_template "main.json")
    STACK_POLICY=$(get_stack_property policy)
    STACK_TEMPLATES=$(get_stack_templates)
    STACK_PARAMETERS=$(get_stack_parameters)
    STACK_PATTERNS=$(get_stack_patterns)
    STACK_INITIALIZERS=$(get_stack_initializers)

    if [ "${STACK_NAME}" == "" ]; then
        error "No stack name provided."
        return 3
    fi
    verbose "STACK_NAME=${STACK_NAME}"
    if [ "${BUCKET_NAME}" == "" ]; then
        error "No bucket name provided."
        return 4
    fi
    verbose "BUCKET_NAME=${BUCKET_NAME}"
    if [ "${AWS_REGION}" == "" ]; then AWS_REGION="${DEFAULT_AWS_REGION}"; fi
    verbose "Using AWS_REGION=${AWS_REGION}"
    if [ "${MASTER_TEMPLATE}" == "" ]; then MASTER_TEMPLATE="${DEFAULT_MASTER_TEMPLATE}"; fi
    verbose "Using MASTER_TEMPLATE=${MASTER_TEMPLATE}"
    if [ "${STACK_POLICY}" == "" ]; then STACK_POLICY="${DEFAULT_STACK_POLICY}"; fi
    verbose "Using STACK_POLICY=${STACK_POLICY}"
    if [ "${SOURCE_DIRS}" == "" ]; then SOURCE_DIRS="${DEFAULT_SOURCE_DIRS}"; fi
    verbose "Using SOURCE_DIRS=${SOURCE_DIRS}"
    if [ "${TARGET_DIR}" == "" ]; then TARGET_DIR="${DEFAULT_TARGET_DIR}"; fi
    verbose "Using TARGET_DIR=${TARGET_DIR}"
}




TEMPLATES_PATH="templates"
POLICIES_PATH="policies"
INITIALIZERS_PATH="cloud-init"

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
                    template_target="${TARGET_DIR}/cloud-formation/${path}"
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
                mkdir -p $(dirname "${TARGET_DIR}/cloud-formation/${path}")
                writeln "Using policy ${policy}"
                cp -f "${policy}" "${TARGET_DIR}/cloud-formation/${path}"
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

function compile_initializers {
    local i initializer path source_dir
    extra_verbose "Compiling initializers: ${STACK_INITIALIZERS}"
    for i in $STACK_INITIALIZERS; do
        initializer=""
        for path in "${i}" "${INITIALIZERS_PATH}/${i}"; do
            for source_dir in $SOURCE_DIRS; do
                initializer="${source_dir}/${path}"
                if [ -f "${initializer}" ]; then
                    writeln "Using initializer ${initializer}"
                    mkdir -p $(dirname "${TARGET_DIR}/cloud-formation/${path}")
                    cp -f "${initializer}" "${TARGET_DIR}/cloud-formation/${path}"
                    break 2
                else
                    initializer=""
                    extra_verbose "Initializer ${path} not found in ${src_dir}/"
                fi
            done
        done
        if [ "${initializer}" == "" ]; then
            error "Could not find initializer '${path} anywhere in ${SOURCE_DIRS}"
            return 2
        fi
    done
}
function compile_stack {
    writeln "Building stack ${STACK_NAME} in ${TARGET_DIR}"
    cleanup "true" || return 1
    compile_templates || return 2
    compile_policy || return 3
    compile_initializers  || return 4
}

function create_bucket {
    local grantees="AuthenticatedUsers"
    local permissions="read write read-acp write-acp"
    if ! $(s3_bucket_exists "${BUCKET_NAME}"); then
        create_s3_bucket "${BUCKET_NAME}" || return 1
        set_s3_bucket_acl "${BUCKET_NAME}" "${grantees}" "${permissions}" | return 2
    fi
}

function sync_bucket {
    sync_s3_bucket "${BUCKET_NAME}" "${TARGET_DIR}" || (error "Sync failed"; return 3 )
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
        ((i++))
    done
    cf_parameters="${cf_parameters}"
    trace "stack-parameters=${cf_parameters}"
    echo -e "${cf_parameters}"
}

function create_stack {
    local parameters=$(create_stack_parameters)
    if cf_stack_exists "${STACK_NAME}"; then
        update_cf_stack --stack "${STACK_NAME}" --bucket "${BUCKET_NAME}" \
            --template ${MASTER_TEMPLATE} --policy "${STACK_POLICY}" \
            --parameters "${parameters}" || return 1
    else
        create_cf_stack --stack "${STACK_NAME}" --bucket "${BUCKET_NAME}" \
            --template ${MASTER_TEMPLATE} --policy "${STACK_POLICY}" \
            --parameters "${parameters}" || return 2
    fi
}

function delete_stack {
    if ! cf_stack_exists "${STACK_NAME}"; then
        warning "Nothing to do. Stack ${STACK_NAME} does not exist"
    else 
        delete_cf_stack "${STACK_NAME}" "wait-for-completion"
    fi
}

function wait_for_completion {
    local status
    if [ "${WAIT_FOR_COMPLETION}" != "" ]; then
        wait_cf_stack "${STACK_NAME}" "${ACTION}" "${WAIT_FOR_COMPLETION}" || return 1
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
if [ "${ACTION}" != "${ACTION_VERIFY}" ]; then
    wait_for_completion || exit 6
fi
cleanup

