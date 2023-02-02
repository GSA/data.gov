# data.gov main repository

[![CircleCI](https://circleci.com/gh/GSA/datagov-deploy.svg?style=svg)](https://circleci.com/gh/GSA/datagov-deploy)

This is the main repository for the Data.gov Platform. We use this repository
primarily to [track our team's work](https://github.com/orgs/GSA/projects/11),
but also to house datagov-wide code (GitHub Actions templates, egress, etc).
If you are looking for documentation for cloud.gov environments, see the
application repositories:

- www.data.gov (Static site on Federerlist). [[repo](https://github.com/GSA/datagov-website)]
- catalog.data.gov (CKAN 2.9) [[repo](https://github.com/GSA/catalog.data.gov)]
- inventory.data.gov (CKAN 2.9) [[repo](https://github.com/GSA/inventory-app)]
- dashboard.data.gov (CodeIgniter PHP) [[repo](https://github.com/GSA/project-open-data-dashboard)]

## GitHub Actions and Templates

A number of our GitHub Actions have been refactored to use templates in this
repository. See templates
[here](https://github.com/GSA/data.gov/tree/main/.github/workflows) and
examples of invoking them in
[Inventory](https://github.com/GSA/inventory-app/blob/76bf4a570f7f4a3b6659b674c6df2547f74d71cd/.github/workflows/commit.yml#L65)
and
[Catalog](https://github.com/GSA/catalog.data.gov/blob/3e99871fd80b7892e24bd40aa03659131298445d/.github/workflows/commit.yml#L87)
.
