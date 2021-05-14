---
name: Offboard team member
about: Checklist for offboarding a team member from Data.gov
title: "[Offboard] <email>"
---

Tasks to be performed by the outgoing team member:
- [ ] Move all Data.gov related documents to team drives
- [ ] Document any work in progress and schedule a hand-off for any remaining tasks

These tasks are performed by a team admin:
- [ ] Remove team member's access to Google Drive
  - [Data.gov](https://drive.google.com/drive/folders/0AMRwhrSyJ5R4Uk9PVA)
  - [Data.gov Mutli Tenant](https://drive.google.com/drive/folders/0ALb0g1S27SJPUk9PVA)
  - [DatagovDevSecOps](https://drive.google.com/drive/folders/1Ac1dUmzTLTsDv8A8TSyLzrXo1a7hm4NF)
- [ ] Email the ISSO to remove the user from any Google Drive folders or documents owned by security
- [ ] Remove team member from Data.gov GitHub teams
  - [data-gov-admins](https://github.com/orgs/GSA/teams/data-gov-admin/members)
  - [data-gov-support](https://github.com/orgs/GSA/teams/data-gov-support/members)
  - [data-gov-ckan-multi](https://github.com/orgs/GSA/teams/data-gov-ckan-multi/members)
- [ ] Remove team member from [the `gsa-datagov` organization](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/users) on cloud.gov
- [ ] Remove team member from [GCP account](https://console.cloud.google.com/iam-admin/iam?project=tts-datagov)
- [ ] Remove team member from AWS OPP account
- [ ] Remove team member from [the SSB staging AWS account](https://054110281448.signin.aws.amazon.com/console)
- [ ] Remove team member from [AWS sandbox access](https://github.com/GSA/datagov-iam/blob/main/README.md#new-users)
- [ ] Remove team member from [jumpbox operators](https://github.com/GSA/datagov-deploy/blob/master/ansible/group_vars/all/vars.yml)
- [ ] Remove team member from Data.gov email lists
  - [datagov](https://groups.google.com/a/gsa.gov/forum/#!forum/datagov)
  - [datagovhelp](https://groups.google.com/a/gsa.gov/forum/#!forum/datagovhelp)
  - [inventory-help](https://groups.google.com/a/gsa.gov/forum/#!forum/inventory-help)
- [ ] Remove team member from [Data.gov calendar](https://calendar.google.com/calendar/r/settings/calendar/Z3NhLmdvdl9zcjZ0NG52YjRhOTNjNnNzdHRxYXAzbjZtMEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t) and events
- [ ] Remove team member from [Login.gov team](https://dashboard.int.identitysandbox.gov/teams/174).
- [ ] Remove team member from [New Relic](https://newrelic.com)
- [ ] Remove team member from [Docker Hub](https://cloud.docker.com/orgs/datagov/teams)
- [ ] Remove team member from [Data.gov system accounts](https://github.com/GSA/datagov-deploy/wiki/CKAN-commands#system-administrator-accounts) on Inventory and Catalog
- [ ] Remove team member from TTS Bug Bounty access [#bug-bounty-partners](https://gsa-tts.slack.com/messages/C5JQCD9PH)
- [ ] Remove team member from [Snyk](https://app.snyk.io/org/data.gov/manage/members)
- [ ] Remove team member from [Agari](https://gsa-tts.bp.agari.com/) (see [#admins-dmarc](https://gsa-tts.slack.com/archives/CNDTG5ML5) or @adborden for access)
- [ ] Remove team member from [Data.gov Google Analytics](https://analytics.google.com/analytics/web/#/a42145528w85560911p88728213/admin/suiteusermanagement/account) account
- [ ] [Rotate Ansible Vault key](https://github.com/GSA/datagov-deploy/wiki/Keypair-Rotation#ansible-vault) and [update the canonical location](https://docs.google.com/document/d/1detdsnIuwmqz6asrIfUWrmxCr56MGschY1yV0UeC_24/edit)
- [ ] Remove team member from PyPI packages:
  - https://pypi.org/project/ckanext-dcat-usmetadata/

If team member is also leaving TTS:
- [ ] Remove team member from Slack

If the team member is also leaving GSA:
- [ ] Request the user be removed from Federalist by posting to [#federalist-support](https://gsa-tts.slack.com/archives/C1NUUGTT5) with the member's GitHub username
- [ ] Remove access from [GSA GitHub org](https://github.com/GSA/GitHub-Administration/blob/master/README.md#removing-access-to-the-gsa-organization)
- [ ] Create "Offboard from GSA IT" ticket
- [ ] Notify HSPD-12 if needed
