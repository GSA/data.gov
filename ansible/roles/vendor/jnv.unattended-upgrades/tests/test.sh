#!/bin/bash

# Exit on any individual command failure
set -e

# Pretty colors.
red='\033[0;31m'
green='\033[0;32m'
neutral='\033[0m'

section() {
  echo -e "\033[33;1m$1\033[0m"
}

fold_start() {
  echo -e "travis_fold:start:$1\033[33;1m$2\033[0m"
}

fold_end() {
  echo -e "\ntravis_fold:end:$1\r"
}

# Ensure we are in the tests dir
cd "$( dirname "${BASH_SOURCE[0]}" )"

section "Syntax check"
ansible-playbook -i inventory --syntax-check test.yml
section "Running role"
ansible-playbook -i inventory test.yml
