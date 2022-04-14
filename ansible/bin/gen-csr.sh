#!/bin/bash
#
# https://github.com/gsa/data.gov/wiki/TLS-SSL-Certificates
#
# Generates a CSR for a list of domains suitable for the GSA certificate
# program. SANs are read from stdin.
#
# CSR requirements are described in Service Now
# https://docs.google.com/document/d/1VzyUAf2LuaNCWGt-ZU94kqq4DWMexmIKxHtjj_JyGDA/edit

set -o errexit
set -o pipefail
set -o nounset

RSA_KEY_LENGTH=2048
# datagov-deploy/ansible/gen-csr-out
output_dir="$(dirname "$0")/../gen-csr-out"

function usage () {
  cat <<EOF
$0: [certificate-name]

Generates a CSR from list of SANs from stdin.
EOF
}

function check_requirements () {
  if ! (command -v openssl) &> /dev/null; then
    echo "$0 requires openssl to be installed." >&2
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

certificate_name=${1:-''}
if [[ -z "$certificate_name" ]]; then
  usage >&2
  exit 1
fi

# check the requirments before continuing
check_requirements

# create the output directory for generated files
mkdir -p "$output_dir"

# Generate a key
key_file="$output_dir/${certificate_name}.key"
if [ ! -r "$key_file" ]; then
  openssl genrsa -out "$key_file" "$RSA_KEY_LENGTH"
fi

# Grab the first domain as the common name
read common_name

# Generate the CSR
csr_file="$output_dir/${certificate_name}.csr"
openssl req -new -nodes -key "$key_file" -out "$csr_file" -config <(
cat <<EOF
[req]
default_bits = "$RSA_KEY_LENGTH"
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
emailAddress=datagovhelp@gsa.gov
CN = $common_name

[ req_ext ]
# Server Authentication (1.3.6.1.5.5.7.3.1) required by GSA
extendedKeyUsage = 1.3.6.1.5.5.7.3.1
subjectAltName = @alt_names

[ alt_names ]
$((echo $common_name; cat) | san_hosts)
EOF
)

echo "CSR and key files generated in $output_dir." >&2
