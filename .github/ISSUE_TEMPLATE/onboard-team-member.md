---
name: Onboard team member
about: Checklist for onboarding a new team member to Data.gov
title: "[Onboard] <email>"
---
Welcome! [The Onboarding wiki](https://github.com/gsa/data.gov/wiki/Onboarding-Offboarding) describes the onboarding process for new team members on Data.gov. You’ll learn mostly from pairing and interaction with your teammates but these are some handy resources to get you started.

Below are the tasks that will drive the onboarding process.

### Tasks for admin or onboarding buddy

- [ ] Review the rest of the checklist below before starting to work through it. Any step that does not seem relevant or necessary for the kind of work that the person onboarding will be doing should have a `-` in the checkbox and `~` around the line so it's clear that we will not be granting that particular kind of access for this person.
- [ ] Add team member to [TTS Slack](https://handbook.18f.gov/slack/#tts-staff)
  - #datagov-alerts
  - #datagov-devsecops
  - #datagov-notifications
- [ ] Add team member to [TTS Slack user groups](https://slack.com/help/articles/212906697-Create-a-user-group#edit-a-user-group)
  - @datagov-team
  - @datagov-dev-team (if applicable)
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
- [ ] Add team member to [Google Groups](https://groups.google.com/my-groups)
  - datagov-team
  - DataGov
  - Data.gov Help
- [ ] Make sure team member has 2FA enabled for their GitHub account and [request](https://github.com/GSA/GitHub-Administration/blob/master/README.md#requesting-access-to-the-gsa-organization) membership to GSA GitHub org
- [ ] Add team member to a Data.gov GitHub team, and change their role to Maintainer if they are part of the PMO team:
  - [ ] for non-development roles: [data-gov-team](https://github.com/orgs/GSA/teams/data-gov-team)
  - [ ] for development roles: [data-gov-dev-team](https://github.com/orgs/GSA/teams/data-gov-dev-team)
- [ ] Add team member to [New Relic](https://account.newrelic.com/accounts/1601367/users) with Full Platform access, along with the following user groups:
  - Solutions-Data.gov
  - Solutions-Data.gov_Admin
- [ ] Add team member to [Snyk](https://app.snyk.io/org/data.gov/manage/members)
- [ ] Add team member to [Data.gov Google Analytics](https://analytics.google.com/analytics/web/#/a42145528p381392243/admin/suiteusermanagement/account) account
  - Choose Viewer role for Contractors, or Administrator for PMO team members
- [ ] [Invite user](https://account.fr.cloud.gov/invite) to Cloud.gov platform
- [ ] Once user has a Cloud.gov account, add team member to the [gsa-datagov organization](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/users/manage?setByUsername=true) and give them access to the following roles
  - Organization: gsa-datagov -- User
  - All spaces - Developer
- [ ] Add team member to the SSB AWS accounts \
      Make a PR on [the Terraform file controlling access](https://github.com/18F/aws-admin/blob/main/terraform/datagov-iam.tf) to add the new person and include them in the appropriate user_groups.
      
  - [See here](https://docs.google.com/document/d/1mwASz1SDiGcpbeSTTILrliDsUKzg1mjy2u11JmvFW2k/edit?usp=drive_link) for AWS Account ID and access instructions
- [ ] Invite team member to Cloud.gov Pages [organization] (https://cloud.gov/pages/documentation/adding-users/#adding-a-new-user)
- [ ] Once member had logged into Login.gov, add them to the [data.gov team](https://dashboard.int.identitysandbox.gov/teams/174) with appropriate role.
- [ ] Invite team member to [Touchpoints](https://touchpoints.digital.gov/) if they don't already have an account.
  - [ ] Once team member has created a Touchpoints account, add them as as form manager to any Data.gov [Touchpoints form](https://touchpoints.app.cloud.gov/)

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
- [ ] Add team member with OrgManager permissions in [the `gsa-datagov` organization](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/users) on cloud.gov
- [ ] Add team member to Github PMO teams and set their role as Maintainer
  - [data-gov-admins](https://github.com/orgs/GSA/teams/data-gov-admin/members) 
  - [data-gov-bots](https://github.com/orgs/GSA/teams/data-gov-bots/members) for dev roles
- [ ] Invite team member to calendar events
- [ ] Promote team member to Admin in [New Relic](https://account.newrelic.com/accounts/1601367/users)
- [ ] Add team member as an Owner to PyPI packages:
  - [ckanext-usmetadata](https://pypi.org/project/ckanext-usmetadata/)
  - [ckanext-metrics-dashboard](https://pypi.org/project/ckanext-metrics-dashboard/)
  - [ckanext-datagovtheme](https://pypi.org/project/ckanext-datagovtheme/)
  - [ckanext-datagovcatalog](https://pypi.org/project/ckanext-datagovcatalog/)`
  - [ckanext-datajson](https://pypi.org/project/ckanext-datajson/)
  - [ckanext-geodatagov](https://pypi.org/project/ckanext-geodatagov/)
  - [datagvo-harvesting-logic](https://pypi.org/project/datagov-harvesting-logic/)
  - [ckanext-dcat-usmetadata](https://pypi.org/project/ckanext-dcat-usmetadata/)
  - [ckanext-gooogleanalyticsbasic](https://pypi.org/project/ckanext-googleanalyticsbasic/)

### Tasks for new team member

- [ ] Log into [Login.gov dashboard](https://login.gov/)
  - [ ] Ensure that you set up PIV as part of your 2FA in [Login.gov](https://login.gov/)
  - [ ] Test logging into [Login.gov Sandbox](https://dashboard.int.identitysandbox.gov/)
- [ ] Ensure your GitHub account meets the criteria for [GSA GitHub org](https://github.com/GSA/GitHub-Administration/blob/master/README.md) (setup 2FA)
- [ ] Configure your Github profile to [sign commits]
  - Follow Github's instructions for generating a GPG key [here](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
  - Or use the SSH key you already [have](https://calebhearth.com/sign-git-with-ssh). More [here]((https://github.com/GSA/data.gov/issues/4768#issuecomment-2471611946)).
- [ ] Read through the [required reading list](https://github.com/gsa/data.gov/wiki/Onboarding-Offboarding#required-reading-list)
  - [ ] Once you have access to cloud.gov, run through [training](https://github.com/gsa/data.gov/wiki/cloud.gov#onboarding-training)
- [ ] [Request access](https://docs.google.com/forms/d/e/1FAIpQLSetStmwqrbMWDz_WIlh1trjhP0PFCjKXHzshsJveYmtIvlG2Q/viewform) to Data.gov systems; select “Catalog Admin” for the system, and “Data.gov team member” for justification
- [ ] Join [Open Data](https://digital.gov/communities/open-data/) community list
- [ ] Request access to the [Digital Analytics Program](https://digital.gov/guides/dap/gaining-access-to-dap-data/)
