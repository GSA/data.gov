#!/bin/bash
# Takes ansible-playbook-like arguments. Starts a docker container then runs
# the ansible playbook. After the playbook runs, it saves the container image.

set -o errexit
set -o pipefail
set -o nounset

function usage () {
  echo "$0: <target-name> <base-image> [ansible-playbook arguments...]" >&2
}

# Parse the arguments
target=${1:-''}
platform=${2:-''}
shift
shift

# The rest of the args are passed to ansible-playbook
ansible_playbook_args="$@"

if [[ -z "$target" || -z "$platform" ]]; then
  usage
  exit 1
fi

function build-for-platform () {
  local platform=$1
  local tag=$target:$platform
  local name=$target-$platform

  echo Building $tag...

  # try to cleanup any existing containers
  docker rm --force $name &> /dev/null || true

  # Start the container based on $platform
  docker run -d --name $name $platform sh -c "while true; do sleep 10000; done" > /dev/null

  # Ansible it up
  (
    cd ../ansible
    ansible-playbook --connection docker --inventory inventories/docker --limit $name $ansible_playbook_args
  )

  # Save the container
  docker commit --message "$target playbook" --author "data.gov" $name $tag
  echo Saved image $tag
  docker rm --force $name
}

build-for-platform $platform
