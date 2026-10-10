---
name: Harvest Source Management Request
about: Template to manage a harvest source
title: 'Harvest source change: '
labels: 'harvest-source, metadata'
assignees: ''

---
Private or internal request details should not be included in this public issue.

## Description & Requested Outcome

We need to create or update a Metadata Harvest Source in the harvesting system under the appropriate parent organization once all required prerequisites are met.

This request may be related to information collected through an internal intake process. Do not include private survey responses, internal-only details, or non-public links in this public issue.
Touchpoints form location: 
* Internal Link: https://touchpoints.app.cloud.gov/admin/forms/ffb7e9d0
* Public Link: https://touchpoints.app.cloud.gov/touchpoints/ffb7e9d0
Internal GSA Google Drive for form printouts: https://drive.google.com/drive/folders/1XJnjv9kfeBMq_CZaj4y1ACDEtkokPq3e?usp=drive_link

## Parent organization

Organization: `[Organization Name]`

Harvest Organization URL: `[Organization URL]`

## Harvest source details

Source name: `[Harvest Source Name]`

Source URL:  `[Confirmed source URL]`

Metadata format/profile:

- [ ] DCAT-US 1.1
- [ ] DCAT-US 3
- [ ] ISO
- [ ] CSW
- [ ] Other: `[Specify]`
- [ ] To be confirmed

## Tasks

- [ ] Confirm (test) the source URL link.
- [ ] Add new harvest source to Data.gov Harvester Dev environment.
- [ ] Send Harvester Dev Environment test report to agency POC.
- [ ] Confirm Path A or Path B below with agency POC

## Path A
- [ ] Setup new, additional harvest source record so that agency has additional DCAT US 3 harvest source.
- [ ] Turn on harvesting of new harvest source
- [ ] Let agency transition datasets (etc) from DCAT US 1.1 harvest source to DCAT US 3 harvest source
- [ ] Wait for agency to confirm all datasets (etc) have been transitioned
- [ ] Clear and then delete old harvest source
- [ ] Send confirmation to agency POC
- [ ] Note any troubleshooting items in comments below

## Path B
- [ ] Confirm date to stop harvesting "old" harvest source
- [ ] Make note of harvest source timing as daily, weekly, monthly, other: 
- [ ] Edit harvest source to stop harvesting and send notification to agency
- [ ] Wait for agency to switch/modify/edit their JSON file and send confirmation back that changes have been made
- [ ] Edit harvest source to reference DCAT US 3 and resume harvesting as previously noted.
- [ ] Send confirmation to agency POC
- [ ] Note any troubleshooting items in comments below

## Final Acceptance criteria

- [ ] A new or updated Metadata Harvest Source exists under the correct parent organization.
- [ ] The harvest source uses the confirmed source URL.
- [ ] The source is configured for the appropriate metadata format/profile.
- [ ] An initial harvest has completed successfully.
- [ ] Any harvest errors or validation issues have been reviewed and documented.
- [ ] Follow-up actions, if any, have been captured in this issue or linked issues.
