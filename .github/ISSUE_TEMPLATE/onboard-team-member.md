---
name: Onboard team member
about: Checklist for onboarding a new team member to Data.gov
title: "[Onboard] <email>"
---
Welcome! [The Onboarding wiki](https://github.com/GSA/datagov-deploy/wiki/Onboarding-Offboarding) describes the onboarding process for new team members on Data.gov. You’ll learn mostly from pairing and interaction with your teammates but these are some handy resources to get you started.

Below are the tasks that will drive the onboarding process.


### Tasks for admin or onboarding buddy

- [ ] Add team member to [TTS Slack](https://handbook.18f.gov/slack/#tts-staff) and #datagov-devsecops
- [ ] Invite team member to [Data.gov calendar](https://calendar.google.com/calendar/r/settings/calendar/Z3NhLmdvdl9zcjZ0NG52YjRhOTNjNnNzdHRxYXAzbjZtMEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t) and events
  - Daily sync
  - Sprint planning
  - Retro
- [ ] Add team member to Google Drive
  - [Data.gov](https://drive.google.com/drive/folders/0AMRwhrSyJ5R4Uk9PVA)
  - [DevSecOps](https://drive.google.com/drive/folders/1Ac1dUmzTLTsDv8A8TSyLzrXo1a7hm4NF)
- [ ] Add team member to email lists
  - [Data.gov team list](https://groups.google.com/a/gsa.gov/forum/#!forum/datagovhelp)
  - [Inventory help list](https://groups.google.com/a/gsa.gov/forum/#!forum/inventory-help)
- [ ] Make sure team member has 2FA enabled for their GitHub account and [request](https://github.com/GSA/GitHub-Administration/blob/master/README.md#requesting-access-to-the-gsa-organization) membership to GSA GitHub org
- [ ] Add team member to [data-gov-support](https://github.com/orgs/GSA/teams/data-gov-support/members) GitHub team
- [ ] Request TTS Bug Bounty access [#bug-bounty-partners](https://gsa-tts.slack.com/messages/C5JQCD9PH)
- [ ] Add team member to Uptrends via [email](https://docs.google.com/spreadsheets/d/1Z9Zpr1mpx-65i_fH2VTbVofPtidpLZs5cnkO0Jz53Vc/edit#gid=0)
- [ ] Add team member to [New Relic](https://newrelic.com)
- [ ] Add team member to [Docker Hub](https://cloud.docker.com/orgs/datagov/teams)
- [ ] Add team member to [Snyk](https://app.snyk.io/org/data.gov/manage/members)


For new Project Management Office team members, follow these additional steps:

- [ ] Add team member to Google Drive
  - [CKAN Mutli](https://drive.google.com/drive/folders/0ALb0g1S27SJPUk9PVA)
- [ ] Add team member to email lists
  - [Data.gov support list](https://groups.google.com/a/gsa.gov/forum/#!forum/datagov)
- [ ] Add team member to #datagov-pmo (PMO only)
- [ ] Add team member to Data.gov slack channels
  - #bug-bounty
  - #bug-bounty-partners
  - #datagov-alerts
  - #datagov-ckan-multi
  - #datagov-comms
  - #datagov-devsecops
  - #datagov-notifications
  - #opp-data-analytics
- [ ] Add team member to [data-gov-admins](https://github.com/orgs/GSA/teams/data-gov-admin/members) GitHub team
- [ ] Invite team member to calendar events
  - CKAN-multi project syncs
  - FGDC meeting
  - CKAN Gov Working group


### Tasks for new team member

- [ ] Ensure your GitHub account meets the criteria for [GSA GitHub org](https://github.com/GSA/GitHub-Administration/blob/master/README.md) (setup 2FA)
- [ ] Read through the [required reading list](https://github.com/GSA/datagov-deploy/wiki/Onboarding-Offboarding#reading-list)
- [ ] [Request access](https://docs.google.com/forms/d/e/1FAIpQLSetStmwqrbMWDz_WIlh1trjhP0PFCjKXHzshsJveYmtIvlG2Q/viewform) to Data.gov systems; select “Catalog Admin” for the system, and “Data.gov team member” for justification
- [ ] Add yourself for [AWS sandbox access](https://github.com/GSA/datagov-infrastructure-live/tree/master/iam#new-users)
- [ ] Request access to AWS OPP account from team member
- [ ] Add your public SSH key to the Ansible vault
  - Request the Ansible Vault keys from team member
  - Clone the [datagov-deploy](https://github.com/GSA/datagov-deploy) repo
    locally
  - Follow the setup instructions for [development](https://github.com/GSA/datagov-deploy/blob/develop/README.md#development)
  - Follow the [ansible-vault instructions](https://github.com/GSA/datagov-deploy#editing-vault-secrets)
  - Edit the vault file `pipenv run ansible-vault edit ansible/group_vars/all/vault.yml` and add your public SSH key
- [ ] Join the international [CKAN Government Working Group](https://docs.google.com/document/d/1d04ZmvSCjb3zhsIZW01wSkoRSzIiLyWen5Z8iwfzhIU/edit)
- [ ] Join [Open Data](https://digital.gov/communities/open-data/) community list
