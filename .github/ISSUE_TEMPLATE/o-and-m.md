---
name: Operations+Maintenance Rotation
about: For keeping track of typical O+M tasks
title: 'O+M'
labels: ''
assignees: ''
---
As part of day-to-day operation of Data.gov, there are many [Operation and Maintenance (O&M) responsibilities](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities). Instead of having the entire team watching notifications and risking some notifications slipping through the cracks, we have created an [O&M Triage role](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#om-triage-rotation). One person on the team is assigned the Triage role which rotates each sprint. _This is not meant to be a 24/7 responsibility, only East Coast business hours. If you are unavailable, please note when you will be unavailable in Slack and ask for someone to take on the role for that time._

Each day, you should start your triage by looking through the notification channels for anything **urgent** that came in after hours that might need immediate attention:

- [#datagov-alerts](https://gsa-tts.slack.com/archives/C4RGAM1Q8) may contain critical host alerts
- [Bug bounty report (ad-hoc email)](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#bug-bounty-report-ad-hoc-email)
- [Vulnerable dependency notifications (daily email reports)](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#vulnerable-dependency-notifications-daily-email-reports)


## Acceptance criteria

You are responsible for all [O&M responsibilities](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities) this week. We've highlighted a few so they're not forgotten.

- [ ] [Audit log updated](https://docs.google.com/spreadsheets/d/1z6lqmyNxC7s5MiTt9f6vT41IS2DLLJl4HwEqXvvft40/edit) for [AU-6 Log auditing](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#au-6-log-auditing) (**Friday**).
- [ ] Any [New Relic alerts](https://alerts.newrelic.com/accounts/1601367/incidents) have been addressed or GH issues created.
- [ ] Weekly [Nessus scan](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#nessus-host-scan-report-from-isso) has been triaged.
- [ ] Weekly [Snyk scan](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#automated-dependency-updates-ad-hoc-github-prs) is complete.
- [ ] Weekly [resources.data.gov link scan](https://app.circleci.com/pipelines/github/GSA/resources.data.gov?branch=main)
- [ ] If received, the monthly [Netsparker scan](https://github.com/GSA/datagov-deploy/wiki/Operation-and-Maintenance-Responsibilities#netsparker-compliance-scan-report-from-isso) has been triaged.
- [ ] Finishing the shift: Log the [number of alerts](https://docs.google.com/spreadsheets/d/1u1hSUAQW6FWzphog122stfB6MB9Wiq0NROT3PeicRoM/edit#gid=939071144) 
