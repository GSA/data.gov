# Contributing

Hello! Thank you for considering a contribution to [Data.gov](https://www.data.gov/). This document describes our team's processes and workflow and includes any tips for making contributions to our GitHub repositories.


## Kanban board

We're currently using GitHub Projects for our [Kanban
board](https://github.com/GSA/datagov-deploy/projects/8).

For project office and security compliance related tasks, see our [Trello board](https://trello.com/b/cTl4qRBr/datagov-team-planning).

### Columns

**Icebox**

Work that has been de-prioritized.


**To do**

Work that we are planning on doing. Work in this column should be well-defined
and ready to begin work.

**In progress** (WIP limit: 2/person)

Work currently in progress. Work that is currently in progress.

**Needs review**

Tasks that are considered done, pending review (code review or some acceptance
testing).

**Reviewer approved**

Tasks that have been reviewed and is ready to merge to the develop branch.


**Merged to develop**

Task has been merged to develop and should be applied to the test/dev environments
(AWS via terraform) and then staging (BSP development).

**Tested**

Task has been applied to both dev and staging environments and is ready to be
pushed to the `master` branch and applied to production (BSP).

**Done**

Task has been applied to production and is considered done.


## Managing deployment

We use the [git flow framework](https://danielkummer.github.io/git-flow-cheatsheet/) for managing our deploys.

Branch | Deployed to | Frequency
------ | ----------- | ---------
`develop` | AWS test-ci | manual
`staging` | BSP dev | manual
`production` | BSP prod | manual


_Note: we don't use the git flow program itself, although you are welcome to
install and use it._