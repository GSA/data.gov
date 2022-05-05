#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -x

# Application may not be fully available immediately, wait 15 seconds
sleep 15

curl --fail --silent ${APP_URL}/api/action/status_show?$(date +%s) > /dev/null
# [ "403" == "$(curl --silent --output /dev/null --write-out %{http_code} ${APP_URL}/dataset?$(date +%s))" ]

echo ok
