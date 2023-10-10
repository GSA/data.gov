---
name: Onboard team member
about: Checklist for onboarding a new team member to Data.gov
title: "[Onboard] <email>"
labels: ''
assignees: ''

---

Welcome! [The Onboarding wiki](https://github.com/gsa/data.gov/wiki/Onboarding-Offboarding) describes the onboarding process for new team members on Data.gov. You’ll learn mostly from pairing and interaction with your teammates but these are some handy resources to get you started.

Below are the tasks that will drive the onboarding process.

### Tasks for admin or onboarding buddy

- [ ] Review the rest of the checklist below before starting to work through it. Any step that does not seem relevant or necessary for the kind of work that the person onboarding will be doing should have a `-` in the checkbox and `~` around the line so it's clear that we will not be granting that particular kind of access for this person.
- [ ] Add team member to [TTS Slack](https://handbook.18f.gov/slack/#tts-staff)
  - #datagov-alerts
  - #datagov-devsecops
  - #datagov-notifications
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
- [ ] Add team member to a Data.gov GitHub team [data-gov-support](https://github.com/orgs/GSA/teams/data-gov-support/members)
- [ ] Add team member to [New Relic](https://account.newrelic.com/accounts/1601367/users) with permissions:
  - Alerts manager
  - APM manager
  - Infrastructure manager
  - Synthetics manager
- [ ] Add team member to [Snyk](https://app.snyk.io/org/data.gov/manage/members)
- [ ] Add team member to [Data.gov Google Analytics](https://analytics.google.com/analytics/web/#/a42145528w85560911p88728213/admin/suiteusermanagement/account) account
- [ ] Add team member as a SpaceDeveloper in the [`development`](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/spaces/eab3d327-7d9f-423b-9838-753c26fdb5a0/users), [`staging`](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/spaces/3e692cdd-6d26-41ea-9698-04903dc3f742/users), and [`management`](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/spaces/9a1db116-0180-42be-8ffa-7944dcf6bf50/summary) spaces in cloud.gov.
  - `$ cf set-space-role <email> gsa-datagov <space> SpaceDeveloper`
- [ ] Add team member to the SSB AWS accounts \
      Make a PR on [the Terraform file controlling access](https://github.com/18F/aws-admin/blob/main/terraform/datagov-iam.tf) to add the new person and include them in the appropriate user_groups.
- [ ] Request Federalist access by posting in [#federalist-support](https://gsa-tts.slack.com/archives/C1NUUGTT5) with the new member's GitHub username.
- [ ] Once member had logged into Login.gov, add them to the [data.gov team](https://dashboard.int.identitysandbox.gov/teams/174).
- [ ] Add team member as form manager to any Data.gov [Touchpoints](https://touchpoints.app.cloud.gov/)

For new Project Management Office team members, follow these additional steps:

- [ ] Add team member to Google Drive
  - [CKAN Mutli](https://drive.google.com/drive/folders/0ALb0g1S27SJPUk9PVA)
- [ ] Add team member to email lists
  - [Data.gov support list](https://groups.google.com/a/gsa.gov/forum/#!forum/datagov)
- [ ] Add team member to #datagov-pmo-private
- [ ] Add team member to additional slack channels
  - #bug-bounty-partners
  - #datagov-comms
  - #sol-data-analytics
- [ ] Add team member to [the GCP project](https://console.cloud.google.com/iam-admin/iam?project=tts-datagov)
- [ ] Add team member with OrgManager permissions in [the `gsa-datagov` organization](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/users) on cloud.gov
- [ ] Add team member to [data-gov-admins](https://github.com/orgs/GSA/teams/data-gov-admin/members) GitHub team
- [ ] Invite team member to calendar events
- [ ] Promote team member to Admin in [New Relic](https://account.newrelic.com/accounts/1601367/users)
- [ ] Add team member as an Owner to PyPI packages:
  - [ckanext-dcat-usmetadata](https://pypi.org/project/ckanext-dcat-usmetadata/)

### Tasks for new team member

- [ ] Log into [Login.gov dashboard](https://dashboard.int.identitysandbox.gov/)
- [ ] Ensure your GitHub account meets the criteria for [GSA GitHub org](https://github.com/GSA/GitHub-Administration/blob/master/README.md) (setup 2FA)
- [ ] Read through the [required reading list](https://github.com/gsa/data.gov/wiki/Onboarding-Offboarding#required-reading-list)
  - [ ] Once you have access to cloud.gov, run through [training](https://github.com/gsa/data.gov/wiki/cloud.gov#onboarding-training)
- [ ] [Request access](https://docs.google.com/forms/d/e/1FAIpQLSetStmwqrbMWDz_WIlh1trjhP0PFCjKXHzshsJveYmtIvlG2Q/viewform) to Data.gov systems; select “Catalog Admin” for the system, and “Data.gov team member” for justification
- [ ] Join [Open Data](https://digital.gov/communities/open-data/) community list
- [ ] Request access to the [Digital Analytics Program](https://digital.gov/guides/dap/gaining-access-to-dap-data/)
