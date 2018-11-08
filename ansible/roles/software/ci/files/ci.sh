#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

declare -A summary

function cleanup () {
  # print summary
  summarize

  #TODO send an email
}

function usage () {
  echo "$0: <ansible inventory>" >&2
}

function summarize () {
  echo
  echo Summary
  echo "==============================="
  for name in "${!summary[@]}"; do
    echo Test case "$name"... "${summary[$name]}"
  done
}

function testcase () {
  local name="$1"
  shift

  echo Test case "$name"...

  # Execute the playbook with any arguments
  echo ansible-playbook "$@"
  if ansible-playbook --inventory "$inventory" --check "$@"; then
    summary[$name]=ok
  else
    summary[$name]=fail
  fi
}

inventory=${1:-''}
if [[ -z "$inventory" ]]; then
  echo You must specify an inventory. >&2
  usage
  exit 1
fi


# Set trap for cleanup tasks
trap cleanup EXIT

cd "$HOME/datagov-deploy/ansible"
git pull

testcase ci ci.yml --limit jumpbox
testcase catalog-web catalog.yml --tags="frontend,ami-fix,bsp" --skip-tags="solr,db,cron,trendmicro,fluentd" --limit catalog-web
testcase catalog-harvest catalog.yml --tags="harvest,ami-fix,bsp" --skip-tags="solr,db,cron,trendmicro,fluentd" --limit catalog-harvester
