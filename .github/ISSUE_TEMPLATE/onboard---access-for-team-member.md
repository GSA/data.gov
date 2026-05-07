---
name: Onboard & Access for team member
about: Checklist for technical onboarding a new team member to Data.gov
title: "[Onboard] Name"
labels: ''
assignees: ''

---

Welcome! [The Onboarding wiki](https://github.com/gsa/data.gov/wiki/Onboarding-Offboarding) describes the onboarding process for new team members on Data.gov. You’ll learn mostly from pairing and interaction with your teammates but these are some handy resources to get you started.  Below are the tasks that will drive the onboarding process.

### Self-Service New Employee Tasks
- [ ] Log into [Login.gov dashboard](https://secure.login.gov/) or create account with GSA email address,   Once an account is created, click "Add Your Government Employee ID" in the left hand nav, and add your PIV card to the account (if you were issued one).  Test logging into [Login.gov Sandbox](https://dashboard.int.identitysandbox.gov/)
- [ ] Ensure your GitHub account meets the criteria for [GSA GitHub org](https://github.com/GSA/GitHub-Administration/blob/master/README.md) (setup 2FA)
- [ ] Configure your Github profile to [sign commits] Follow Github's instructions for generating a GPG key [here](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key).  Or use the SSH key you already [have](https://calebhearth.com/sign-git-with-ssh). More [here]((https://github.com/GSA/data.gov/issues/4768#issuecomment-2471611946)).
- [ ] Read through the [required reading list](https://github.com/gsa/data.gov/wiki/Onboarding-Offboarding#required-reading-list)
  - [ ] Once you have access to cloud.gov, run through [training](https://github.com/gsa/data.gov/wiki/cloud.gov#onboarding-training)

### Contractor Onboarding Buddy Tasks
- [ ] Once member had logged into Login.gov, add them to the [data.gov team](https://dashboard.int.identitysandbox.gov/teams/174) with appropriate role.
- [ ] Add team member to [Data.gov Google Analytics](https://analytics.google.com/analytics/web/#/a42145528p381392243/admin/suiteusermanagement/account) account
- [ ] Add team member to [Google Search Console](https://search.google.com/search-console/users?resource_id=sc-domain%3Adata.gov)

### Gov Employee Tasks

**GitHub**
- [ ] Review this ticket and modify it as necessary
- [ ] Make sure team member has 2FA enabled for their GitHub account and [request](https://github.com/GSA/GitHub-Administration/blob/master/README.md#requesting-access-to-the-gsa-organization) membership to GSA GitHub org
- [ ] Add team member to a Data.gov GitHub teams such as [data-gov-dev-team](https://github.com/orgs/GSA/teams/data-gov-dev-team), and change their role to Maintainer if they are part of the PMO team. For non-development roles that aren't PMO, add them to [data-gov-team](https://github.com/orgs/GSA/teams/data-gov-team)
- [ ] Add Government team member to Github PMO teams and set their role as Maintainer
  - [data-gov-admins](https://github.com/orgs/GSA/teams/data-gov-admin/members) 
  - [data-gov-bots](https://github.com/orgs/GSA/teams/data-gov-bots/members) for dev roles

**Slack**
- [ ] Add ALL team members to Slack Channels such as #datagov-____ (unlocked); #dev; #admins-github; #g-content; #cloud-engineering; #login-partner-support
- [ ] Add ALL team members to [TTS Slack user groups](https://slack.com/help/articles/212906697-Create-a-user-group#edit-a-user-group) such as @datagov-team and @datagov-dev-team
- [ ] Add **Government** team member to additional slack channels (#datagov-__ (Locked))
- [ ] Add **Government** team member as a collaborator for our Slack App that manages webhook notifications <https://api.slack.com/apps/A03F7BJBMMF/>

**Google**
- [ ] Invite ALL team members to [Data.gov calendar events](https://calendar.google.com/calendar/r/settings/calendar/Z3NhLmdvdl9zcjZ0NG52YjRhOTNjNnNzdHRxYXAzbjZtMEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t)
- [ ] Add ALL team members to Google Drive [Data.gov](https://drive.google.com/drive/folders/0AMRwhrSyJ5R4Uk9PVA)
- [ ] Add ALL team members to Google Groups & Emails: datagovhelp@gsa.gov; datagovteam@gsa.gov; datagov@gsa.gov; inventory-help@gsa.gov; 

**Cloud.gov**
- [ ] [Invite user](https://account.fr.cloud.gov/invite) to Cloud.gov platform and add team member to the [gsa-datagov organization](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/users/manage?setByUsername=true) and give them access to the following roles:  Organization: gsa-datagov -- User; All spaces - Developer
- [ ] Invite team member to Cloud.gov Pages [organization] (https://cloud.gov/pages/documentation/adding-users/#adding-a-new-user)
- [ ] Add **Government** team members with OrgManager permissions in [the `gsa-datagov` organization](https://dashboard.fr.cloud.gov/cloud-foundry/2oBn9LBurIXUNpfmtZCQTCHnxUM/organizations/90047c5d-337f-4802-bd48-2149a4265040/users) on cloud.gov

### Needs Special Review due to limited licenses or limited need
- [ ] Add team member to [New Relic](https://account.newrelic.com/accounts/1601367/users) with Full Platform access, along with the following user groups: Solutions-Data.gov; Solutions-Data.gov_Admin
- [ ] Promote Government team member to Admin in [New Relic](https://account.newrelic.com/accounts/1601367/users)
- [ ] Add team member to [Docker Hub](https://cloud.docker.com/orgs/datagov/teams)
- [ ] Add team member to [Snyk](https://app.snyk.io/org/data.gov/manage/members)
  - Choose Viewer role for Contractors, or Administrator for PMO team members
  - Grant "Full" permissions for Contractors, and "Owner" permissions for PMO team members
- [ ] Add team member to the SSB AWS accounts: Make a PR on [the Terraform file controlling access](https://github.com/18F/aws-admin/blob/main/terraform/datagov-iam.tf) to add the new person and include them in the appropriate user_groups.  [See here](https://docs.google.com/document/d/1mwASz1SDiGcpbeSTTILrliDsUKzg1mjy2u11JmvFW2k/edit?usp=drive_link) for AWS Account ID and access instructions
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
