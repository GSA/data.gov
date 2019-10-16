# Contributing

Hello! Thank you for considering a contribution to
[Data.gov](https://www.data.gov/). This document describes our team's processes
and workflow and includes any tips for making contributions to our GitHub
repositories.

We want to ensure a welcoming environment for all of our projects. Our staff follow
the [GSA Code of Conduct](https://github.com/GSA/open-source-policy/blob/master/CODE_OF_CONDUCT.md)
and expect all contributors to do the same.

Data.gov is a small team that is asked to cover a lot of diverse topics and
projects and work across a very broad spectrum of stakeholders. So it is
critical to discuss and communicate often and expectations and preferences for
communication with the team, as soon as you start.

- **Work in the Open** - meaning we default to starting all work in Github open from
  the start; when starting try to consult the team on whether `start` means as
  an idea, issue, crude outline, rough draft, or active work-in-progress.
- **Share everything that is not sensitive** - The team is always respectful to new
ideas, approaches, tools, projects so long as they are not a distraction from
task “Capacity”
- **Agile** - we accept that change is inevitable and design our processes and systems
  to reduce friction and adapt.
- **Family and Yourself first** - work is never as important as family or personal
  demands or health.
- **Stupid questions are not** - Data.gov is a complex program with a long history
  and large group of stakeholders and interested parties. Don’t be afraid to ask
  questions, you will have a lot and getting those answered can only help the
  entire team.


## Kanban board

We're currently using ZenHub for our [Kanban
board](https://app.zenhub.com/workspaces/datagov-devsecops-579a2532d1d6ea9c3fcf5cfa/board).

For Project Management Office and security compliance related tasks, see our
[Incident Response repo](https://github.com/GSA/datagov-incident-response).


### Columns

#### New

New issues that need to be triaged.


#### Icebox

Work that has been de-prioritized.


#### Product backlog

Work that we are planning on doing and will schedule into a sprint.


#### Sprint backlog

Work that we are planning for the current sprint. Work in this column should be
well-defined and ready to begin work.


#### In progress (WIP limit: 2/person)

Work that is currently in progress.


#### Blocked

Work that has been started but is blocked by an external party and needs
occasional nudging to get it unblocked.


#### Needs review

Tasks that are considered done, pending review (code review or some acceptance
testing).


#### Reviewer approved

Tasks that have been reviewed and is ready to merge to the develop branch.


#### Merged to develop

Task has been merged to develop and should be applied to the test/dev environments
(AWS via terraform) and then staging (BSP development).


#### Tested

Task has been applied to both dev and staging environments and is ready to be
pushed to the `master` branch and applied to production (BSP).


#### Done

Task has been applied to production and is considered done.


## Managing deployment

We use the [git flow
pattern](https://danielkummer.github.io/git-flow-cheatsheet/) to coordinate delivery of features and bugfixes between branches. Generally, new features will arrive in the `develop` branch, then periodically be gathered up and deployed into staging via `release/*` branches, then deployed into production via the `production` branch.  _Note: we don't use the git-flow program itself since work must be merged via pull-requests, which that tool doesn't support._

Branch | Deployed to | Frequency
------ | ----------- | ---------
`develop` | AWS sandboxes | manual
`release/*` | BSP dev | manual
`production` | BSP prod | manual
