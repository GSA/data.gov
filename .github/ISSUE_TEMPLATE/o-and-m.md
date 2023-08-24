---
name: Operations+Maintenance Rotation
about: For keeping track of typical O+M tasks
title: 'O+M'
labels: ''
assignees: ''
---
As part of day-to-day operation of Data.gov, there are many [Operation and Maintenance (O&M) responsibilities](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities). Instead of having the entire team watching notifications and risking some notifications slipping through the cracks, we have created an [O&M Triage role](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#om-triage-rotation). One person on the team is assigned the Triage role which rotates each sprint. _This is not meant to be a 24/7 responsibility, only East Coast business hours. If you are unavailable, please note when you will be unavailable in Slack and ask for someone to take on the role for that time._

Check the [O&M Rotation Schedule](https://docs.google.com/spreadsheets/d/1cF73HkzFuQth3z9voLfVO1Cc4kjBd6ecHGE2gkj5LCc/edit?usp=sharing) for future planning.

## Miscs
-   Watch for user email requests
-   Watch in [#datagov-alerts](https://gsa-tts.slack.com/archives/C4RGAM1Q8) and [Vulnerable dependency notifications (daily email reports)](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#vulnerable-dependency-notifications-daily-email-reports) for critical alerts.
-   Monitor and improve [Data.gov O&M Dashboard](https://onenr.io/0LREMrzdrRa)

## Acceptance criteria
You are responsible for all [O&M responsibilities](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities) this week. We've highlighted a few so they're not forgotten. You can copy each checklist into your daily report.

## Daily Checklist
Check Production State/Actions
- [ ] [README](https://github.com/GSA/data.gov)
> **Note: Catalog Auto Tasks**
> You will need to update the chart values manually. Click the Action link in each issue and grab the values from `monitor task output` and `check runtime`.
- [ ] [DB-Solr Sync](https://github.com/GSA/catalog.data.gov/issues/848)
- [ ] Check [Harvesting Emails](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#harvest-job-report-daily-email-report)
- [ ] [New Relic Alerts](https://alerts.newrelic.com/accounts/1601367/incidents) Triaged
- [ ] Triage DMARC Report from Google

## Weekly Checklist
- [ ] [Audit Log](https://docs.google.com/spreadsheets/d/1z6lqmyNxC7s5MiTt9f6vT41IS2DLLJl4HwEqXvvft40/edit) (more info on [AU-3 and AU-6 Log auditing](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#au-3-and-au-6-log-auditing))
- [ ] [Tracking Update](https://github.com/GSA/catalog.data.gov/issues/847)
    - NOTE: This job will consistently timeout, but it is processing results
- [ ] Check [Catalog Solr](https://github.com/GSA/data.gov/wiki/Operation-and-Maintenance-Responsibilities#solr)
- [ ] [Catalog Dupe Check](https://github.com/GSA/data.gov/wiki/Operation-and-Maintenance-Responsibilities#duplicate-check)

## Monthly Checklist
- [ ] [Invicti Scan](https://github.com/gsa/data.gov/wiki/Operation-and-Maintenance-Responsibilities#netsparker-compliance-scan-report-from-isso)
