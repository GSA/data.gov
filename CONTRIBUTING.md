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


## Sprint rituals

We follow two week sprints with the following rituals.

- Daily standup (daily)
- Sprint planning (first Monday of the sprint)
- Sprint review and retrospective (last Thursday of the sprint)


## Story lifecycle

**Stories** represent tactical increments of individually-valuable work
deliverable by the team within a single iteration... often an isolated change in
functionality aimed at achieving a goal for a particular kind of stakeholder,
whether customer, user, or operator/admin. Stories are tracked on the [Kanban
Board](https://app.zenhub.com/workspaces/datagov-devsecops-579a2532d1d6ea9c3fcf5cfa/board)
and progress through these columns.

- New
- Icebox
- Product backlog
- Sprint backlog
- In progress
- Blocked
- Ready for deploy
- Done
- Closed

For Project Management Office and security compliance related tasks, see our
[Incident Response repo](https://github.com/GSA/datagov-incident-response).


### Definition of "Done"

An agile "Definition of Done" (DoD) captures the team's agreed-upon standards
for how we get work done at a consistent level of quality. Having a DoD ensures
that non-functional requirements (NFRs) don't have to be re-litigated for every
piece of work taken on, cards can be focused on just the relevant details, and
new team members aren't surprised by assumed expectations of their colleagues.

At our sprint reviews, we demo work that has reached the "Done" column and is of
interest to our users or teammates.


#### Column exit criteria

Our DoD is broken up into a set of statements that should be true
for each card before it moves to the next column on the board.

Before advancing a card from one column to the next on the board, it should meet
the "exit criteria" for the current column, which are listed below.


### Columns


#### New

New issues that need to be triaged.


##### Exit criteria

- Relevant points from any discussion in the comments is captured in the initial
  post.
- Decision is made to move to the Backlog or Icebox columns, or close.


#### Icebox

Work that has been de-prioritized.


##### Exit criteria

- When reviewing priorities, we may pull items out of the Icebox.
- Items move to Product backlog for grooming.


#### Product Backlog

Work that we are planning on doing and will groom and schedule into a sprint.


##### Exit criteria

- Indicate the intended benefit and who the story is for in the "as a ..., I want
  ..., so that ..." form.
- Acceptance criteria is defined.
- If necessary, the story includes a security testing plan and any tasks from
  that plan are included as acceptance criteria.


#### Sprint backlog

Work that we are planning for the current sprint. Work in this column should be
well-defined and ready to begin work.


##### Exit criteria

- No info or assistance is needed from outside the team to start work and likely
  finish it.
- There's capacity available to work on the story (e.g., this column is a buffer
  of shovel-ready work).


#### In progress (WIP limit: 2/person)

Work that is currently in progress.


##### Exit criteria

- Acceptance criteria are demonstrably met.
- Relevant tasks complete, irrelevant checklists removed or captured on a new story.
- Follows documented coding conventions.
- Automated tests have been added and are included in Continuous Integration.
- Pair-programmed or peer-reviewed (e.g., use pull-requests).
- Test coverage exists and overall coverage hasn't been reduced.
- User-facing and internal operation docs have been updated.
- Demoable to other people in their own time (e.g., staging environment, published branch).
- Any deployment is repeatable (e.g., at least documented to increase bus factor beyond one) and if possible automated via CI/CD.
- If the deployment is difficult to automate, then a story for making it automated is created at the top of New.
- The deployment must follow our Configuration Management plan. If not possible,
  contact the Program Management team to modify the story or discuss how to
  update the Configuration Management plan.
- Task has been merged to develop/master and should be applied to the AWS sandbox environments.

#### Blocked

Work that has been started but is blocked by an external party and needs
occasional nudging to get it unblocked.


##### Exit criteria

- Third-party blocker has been removed, the story can move to Sprint backlog or
  In progress.


#### Ready for deploy

Task has been merged to develop/master and applied to the sandbox environments
(AWS via terraform) and ready to be deployed BSP staging and production
environments.


##### Exit criteria

- Work exists on a release branch.
- Work has been applied to BSP staging.
- Work has been applied to BSP production.


#### Done

Task has been applied to production and is considered done and should be reviewed with the team as part of the Sprint Review.

##### Exit criteria

- The work is user-visible and announceable at any time.
- The work has been demoed at the Sprint Review.


#### Closed

Task is done and has been reviewed by the team as part of Sprint Review.

##### Exit criteria

- GitHub issue is marked Closed.


## Managing deployment

Deployment works a little differently between the platform
([datagov-deploy][datagov-deploy]) and the application repos (e.g.
[catalog-app](https://github.com/GSA/catalog-app)).

In general, the `master` branch should be in a deployable state at all
times.


### Application deployment

On any change to `master`, the application should be sequentially deployed to
sandbox, staging, and then production. If there's an issue with the deploy along
the way, the deploy should be halted and then the issue addressed (following the
usual PR workflow) before starting a new deploy. See [application
release](https://github.com/GSA/datagov-deploy/wiki/Releases#application-release)
for detailed manual deployment steps.


### Platform deployment (datagov-deploy)

We use `develop` as the default branch and stage releases with a release branch
(`release/*`). The BSP environment can be hard to test in, so having a staged
release allows us to debug and fix BSP issues without slowing down sprint
development.

For [datagov-deploy][datagov-deploy], we use the [git flow
pattern](https://danielkummer.github.io/git-flow-cheatsheet/) to coordinate
delivery of features and bugfixes between branches. Generally, new features will
arrive in the `develop` branch, then periodically be gathered up and deployed
into staging via `release/*` branches, then deployed into production via the
`master` branch.  _Note: we don't use the git-flow program itself since work
must be merged via pull-requests, which that tool doesn't support._

Branch | Deployed to | Frequency
------ | ----------- | ---------
`develop` | AWS sandboxes | manual
`release/*` | BSP dev (staging) | manual
`master` | BSP prod | manual

See [Releases](https://github.com/GSA/datagov-deploy/wiki/Releases) for details
on the platform deployment steps.


#### Hotfixes

Occasionally for the platform, we need to skip the usual development workflow to
address an urgent issue. This is because `develop` requires a lot of manual
testing and might not always be in a deployable state (even though we try).
`hotfix/*` branches are created from the `master` branch and allow us to do the
manual testing and validation on a small set of isolated changes.

Use your discretion when creating a hotfix. These are some reasons to create
a hotfix:
- Resolve a significant site outage
- Fix a major bug
- Change to the Ansible inventory (new/removed hosts)
- Removing operator access

Once the hotfix PR is merged, you should create a backmerge PR into develop (merge
the `hotfix/*` branch into `develop).


[datagov-deploy]: https://github.com/GSA/datagov-deploy
