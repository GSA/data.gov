#!/bin/bash

# Smoke test for testing egress

set -o errexit
set -o pipefail
set -o nounset
set -x

SPACE=$2
ALLOW_DOMAIN="data.gov"
DENY_DOMAIN="bing.com"

function test_egress {
    DOMAIN=$1
    CODE=$2
    [ "$CODE" == "$(curl -I --silent https://"$DOMAIN" | head -n 1 | cut -d$' ' -f2)" ]
}

# Application may not be fully available immediately, wait 15 seconds
sleep 15

if [ "$SPACE" == "egress" ]; then
    # in the egress space, the egress app itself should be able to reach anything
    DENY_CODE=200
elif [ "$SPACE" == "app" ]; then
    # in the app space, the app's egress should be restricted
    DENY_CODE=403
else
    false || echo 'Error: SPACE not found'
fi

test_egress "$ALLOW_DOMAIN" 200
echo "Allow domain ok"

test_egress "$DENY_DOMAIN" "$DENY_CODE"
echo "Deny domain ok"

echo ok
