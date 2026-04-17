# Contributing

Thanks for contributing to Data.gov. This document describes how our team works.

We follow the [GSA Code of Conduct](https://github.com/GSA/open-source-policy/blob/master/CODE_OF_CONDUCT.md) and expect all contributors to do the same.

## How we work

Data.gov is a small team covering a broad portfolio. We work in the open, default to GitHub for all work tracking, and share everything that isn't sensitive.

- **Ask questions** -- Data.gov is a complex program with a long history. There are no stupid questions.
- **Work in the open** -- all work starts as a GitHub issue.
- **Family and yourself first** -- work is never as important as personal demands or health.

## Sprint rituals

We follow two-week sprints.

- Daily standup (daily)
- Sprint planning (first Thursday of the sprint)
- Sprint review and retrospective (last Tuesday of the sprint)

## How we track work

Work is tracked as issues in [GSA/data.gov](https://github.com/GSA/data.gov/issues) and visualized on our [GitHub Projects board](https://github.com/orgs/GSA/projects/11/views/1).

Issue templates are available for common work types:
- Bug reports
- Feature requests
- Security and compliance findings
- Support requests
- Onboarding and offboarding

For security and compliance related work, see our [Incident Response repo](https://github.com/GSA/datagov-incident-response).

## Pull requests

Any developer on the team can review any PR. When reviewing:

- Review for code quality and consistency
- Call out any breaking changes
- Verify tests are written and running in CI
- Verify documentation is updated if applicable
- A single approval is sufficient to merge

## Managing deployment

All application deployments are handled via GitHub Actions on push to `main`. Each application repository has its own deployment workflow that deploys sequentially to staging and then production on cloud.gov.

### Application deployment

Changes merged to `main` trigger an automatic deployment pipeline:

1. Deploy to staging -- runs smoke tests to verify the deployment
2. Deploy to prod -- runs after staging succeeds

If there is an issue with the deploy at any stage, address it via the usual PR workflow before starting a new deploy.

For emergency deployments outside of the normal CI/CD pipeline, see [Break Glass deployment](https://github.com/GSA/data.gov/wiki/Break-Glass-deployment).

### Application repositories

| Application | Repository |
|-------------|------------|
| catalog.data.gov | https://github.com/GSA/datagov-catalog |
| harvest.data.gov | https://github.com/GSA/datagov-harvester |
| inventory.data.gov | https://github.com/GSA/inventory-app |
| www.data.gov | https://github.com/GSA/datagov-website |
| resources.data.gov | https://github.com/GSA/resources.data.gov |
| strategy.data.gov | https://github.com/GSA/data-strategy |
