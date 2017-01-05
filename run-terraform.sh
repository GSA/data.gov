#!/bin/sh

export AWS_PROFILE="ocsit"
#BUCKET=-b com-aquilent-sa-data-gov

#export AWS_PROFILE="gsa-datagov"

PROJECT_HOME=/d/Users/nhunt/git/Data.gov/catalog-deploy
BRANCH_NAME="newbranch1"
VERBOSITY="-v -v"

function do_stack {
    local action="$1"
    local stack_name="$2"
    local status=0
    local status_text=""
    local separator="=========="

    echo "${separator} ${action} ${stack_name} ${separator}"

    pushd "${PROJECT_HOME}/terraform" > /dev/null
    ./bin/manage-stack.sh ${VERBOSITY} ${BUCKET} --action "${action}" \
        "${stack_name}" "${BRANCH_NAME}"
    status=$?
    popd > /dev/null
    if [ "${status}" == "0" ]; then status_text="OK"; else status_text="FAILED"; fi

    echo "${separator} ${action} ${stack_name} => ${status_text} ${separator}"
    return $status
}

function delete_stack {
    do_stack 'delete' "$1" || return 1
}

function create_stack {
    do_stack 'create' "$1" || return 1
}

function recreate_stack {
    local stack_name="$1"
    delete_stack "${stack_name}" || return 1
    create_stack "${stack_name}" || return 2
}

#delete_stack 'infrastructure' || exit 1
create_stack 'pilot' || exit 2

#recreate_stack 'pilot' || exit 3
