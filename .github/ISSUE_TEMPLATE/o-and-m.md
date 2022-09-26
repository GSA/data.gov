---
name: Operations+Maintenance Rotation
about: For keeping track of typical O+M tasks
title: 'O+M'
labels: ''
assignees: ''
---
As part of day-to-day operation of Data.gov, there are many [Operation and Maintenance (O&M) responsibilities](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities). Instead of having the entire team watching notifications and risking some notifications slipping through the cracks, we have created an [O&M Triage role](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#om-triage-rotation). One person on the team is assigned the Triage role which rotates each sprint. _This is not meant to be a 24/7 responsibility, only East Coast business hours. If you are unavailable, please note when you will be unavailable in Slack and ask for someone to take on the role for that time._

## Routine Tasks
- Check Action tabs for each _active_ repositories
  - [Inventory Restart Action](https://github.com/GSA/inventory-app/actions/workflows/restart.yml)
  - [Inventory deploy Action](https://github.com/GSA/inventory-app/actions/workflows/deploy.yml)
  - [Catalog Restart Action](https://github.com/GSA/catalog.data.gov/actions/workflows/restart.yml)
  - [Catalog Deploy Action](https://github.com/GSA/catalog.data.gov/actions/workflows/publish.yml)
  - [Solr Brokerpak Release Action](https://github.com/GSA/datagov-brokerpak-solr/actions/workflows/release.yml)
    - Note the release version
  - [EKS Brokerpak Release Action](https://github.com/GSA/datagov-brokerpak-eks/actions/workflows/release.yml)
    - Note the release version
  - [SMTP Brokerpak Release Action](https://github.com/GSA/datagov-brokerpak-smtp/actions/workflows/release.yml)
    - Note the release version
  - [SSB Deploy Action](https://github.com/GSA/datagov-ssb/actions/workflows/apply.yml)
    - Validate it is using the most recent (working) releases of each brokerpak.
- Verify each Solr Leader/Followers are functional

  Use this command to find Solr URLs and credentials in the `prod` space.
  ```
  $ cf t -s prod
  $ cf env catalog-web | grep solr -C 2 | grep "uri\|solr_follower_individual_urls\|password\|username"
  ```
  - Verify their Start time is in sync with Solr Memory Alert history at path `/solr/#/`
  - Verify each follower stays with Solr leader at path `/solr/#/ckan/core-overview`
  - Verify each Solr is responsive by running a few queries at `/solr/#/ckan/query`
  - Inspect each Solr's logging for abnormal errors at `/solr/#/~logging`

- Examine the Solr Memory Utilization Graph to catch any abnormal incidences.

  Log in to `tts-jump` AWS account with role `SSBDev@ssb-production`, go to custom [SolrAlarm dashboard](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#dashboards:name=SolrAlarms;start=PT24H) to see the graph for the past 24 hours. There should not be any Solr instance has MemoryUtilization go above 90% threshold. Each Solr should not restart too often (more than a few times a week)
- Verify harvesting jobs are running, go through Error reports to catch unusual errors that need attention [[Wiki doc](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#harvest-job-report-daily-email-report)]
- Go through NewRelic logs to make sure each app's log is current
- Watch for user email requests
- Triage DMARC Report from Google (daily) sent to datagovhelp@gsa.gov (only for catalog in prod).
- Watch in [#datagov-alerts](https://gsa-tts.slack.com/archives/C4RGAM1Q8) and [Vulnerable dependency notifications (daily email reports)](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#vulnerable-dependency-notifications-daily-email-reports) for critical alerts.

## Acceptance criteria

You are responsible for all [O&M responsibilities](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities) this week. We've highlighted a few so they're not forgotten.

- [ ] [Audit log updated](https://docs.google.com/spreadsheets/d/1z6lqmyNxC7s5MiTt9f6vT41IS2DLLJl4HwEqXvvft40/edit) for [AU-6 Log auditing](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#au-6-log-auditing) (**Friday**).
- [ ] Any [New Relic alerts](https://alerts.newrelic.com/accounts/1601367/incidents) have been addressed or GH issues created.
- [ ] Weekly [Nessus scan](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#nessus-host-scan-report-from-isso) has been triaged.
- [ ] Weekly [Snyk scan](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#automated-dependency-updates-ad-hoc-github-prs) is complete.
- [ ] Weekly [resources.data.gov link scan](https://app.circleci.com/pipelines/github/GSA/resources.data.gov?branch=main)
- [ ] If received, the monthly [Netsparker scan](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#netsparker-compliance-scan-report-from-isso) has been triaged.
- [ ] Finishing the shift: Log the [number of alerts](https://docs.google.com/spreadsheets/d/1u1hSUAQW6FWzphog122stfB6MB9Wiq0NROT3PeicRoM/edit#gid=939071144) 
