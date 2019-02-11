#!/bin/bash
# This is a poor-person's continuous delivery script
# I'm hoping this is a temporary solution until we get something a little more
# robust, like AWX/Ansible Tower. This script runs all the playbooks necessary
# to build out all the data.gov properties. The script is meant to be run
# regularly in order to update hosts. Eventually, this should all be refactored
# so that it can be run in a single playbook with no tags.

set -o errexit
set -o pipefail
set -o nounset

function usage () {
  echo "$0: <inventory-directory>" >&2
}

inventory="${1:-}"

if [[ -z "$inventory" ]]; then
  usage
  exit 1
fi

ansible-playbook -i "$inventory" site.yml

# TODO refactor the following playbooks into site.yml and then remove this
# script
