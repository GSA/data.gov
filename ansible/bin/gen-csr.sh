#!/bin/bash
# Generates a CSR for the inventory hosts
# suitable for GSA to sign through their
# certificate program.
#
# The script should be run from your ansible directory and assumes
# ansible-inventory, jq, and openssl are already installed and available.
#
# CSR requirements are described in Service Now
# https://docs.google.com/document/d/1VzyUAf2LuaNCWGt-ZU94kqq4DWMexmIKxHtjj_JyGDA/edit

set -o errexit
set -o pipefail
set -o nounset

RSA_KEY_LENGTH=2048
output_dir=gen-csr-out

function usage () {
  cat <<EOF
$0: <ansible-inventory>

Generates a CSR from ansible inventory.
EOF
}

function check_requirements () {
  if ! (command -v jq \
    && command -v openssl \
    && command -v ansible-inventory) &> /dev/null; then


    echo "$0 requires ansible-inventory, jq, openssl to be installed." >&2
    exit 1
  fi
}

function san_hosts () {
  # Formats a list of hosts for SAN configuration in CSR
  local host
  local i=1
  while read host; do
    echo "DNS.$i = $host"
    i=$((i + 1))
  done
}

function ansible_hosts () {
  # Get a flat list of hosts from the ansible inventory
  local inventory=${1}
  ansible-inventory -i "inventories/$inventory" --list | jq -r '.[].hosts[]?' | sort | uniq
}


inventory=${1:-''}

if [ -z "$inventory" ]; then
  usage >&2
  exit 1
fi

# check the requirments before continuing
check_requirements

# create the output directory for generated files
mkdir -p "$output_dir"

# Generate a key
key_file="$output_dir/data-gov-bsp-${inventory}.key"
if [ ! -r "$key_file" ]; then
  openssl genrsa -out "$key_file" "$RSA_KEY_LENGTH"
fi

# Generate the CSR
csr_file="$output_dir/data-gov-bsp-${inventory}.csr"
openssl req -new -nodes -key "$key_file" -out "$csr_file" -config <(
cat <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=District of Columbia
L=Washington
O=General Services Administration
OU=Technology Transformation Service
emailAddress=datagov@gsa.gov
CN = $(ansible_hosts "$inventory" | head -n 1)

[ req_ext ]
# Server Authentication (1.3.6.1.5.5.7.3.1) required by GSA
extendedKeyUsage = 1.3.6.1.5.5.7.3.1
subjectAltName = @alt_names

[ alt_names ]
$(ansible_hosts "$inventory" | san_hosts)
EOF
)

echo "CSR and key files generated in $output_dir."
