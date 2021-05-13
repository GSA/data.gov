#!/bin/bash

set -o errexit
set -o pipefail

hostname=${1}

if [[ -z "$hostname" ]]; then
  echo "Usage: $0 <hostname>" >&2
  exit 1
fi

function test_cipher () {
  local cipher
  cipher=$1
  if echo | openssl s_client -connect $hostname:443 -cipher $cipher -servername $hostname &> /dev/null; then
    echo $cipher enabled
  fi
}

function main () {
  while read cipher; do
    test_cipher $cipher
  done
}

# Convert IANA cipher names to OpenSSL names https://testssl.sh/openssl-iana.mapping.html
main <<EOF
AES128-SHA
AES256-SHA
CAMELLIA128-SHA
DH-DSS-CAMELLIA256-SHA
ECDHE-RSA-AES128-SHA
ECDHE-RSA-AES256-SHA
AES128-SHA256
AES256-SHA256
CAMELLIA128-SHA256
ECDHE-RSA-AES128-SHA256
ECDHE-RSA-AES256-SHA384
ECDHE-RSA-CAMELLIA256-SHA384
ECDHE-RSA-CAMELLIA256-SHA384
EOF