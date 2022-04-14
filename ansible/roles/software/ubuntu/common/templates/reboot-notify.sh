#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# If reboot-required does not exist, we're done
[[ ! -x /var/run/reboot-required ]] && exit 0

sendmail {{ datagov_team_email }} <<EOF
From: reboot-notify <no-reply+reboot-notify@data.gov>
Subject: [reboot-notify] A reboot is required on $(hostname --fqdn)

Hello Data.gov,

A reboot is required on $(hostname --fqdn). Please use the reboot.yml playbook
to reboot this host.

--
reboot-notify is a cron job configured for Data.gov
https://github.com/gsa/data.gov
EOF
