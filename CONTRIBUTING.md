# Contributing

Hello! Thank you for considering a contribution to
[Data.gov](https://www.data.gov/). This document describes our team's processes
and workflow and includes any tips for making contributions to our GitHub
repositories.

We want to ensure a welcoming environment for all of our projects. Our staff follow
the [GSA Code of Conduct](https://github.com/GSA/open-source-policy/blob/master/CODE_OF_CONDUCT.md)
and expect all contributors to do the same.


## Principles

1. Our work is transparent and open
1. We start with user needs
1. We follow Agile and DevOps methodology


### Our work is transparent and open

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


### We start with user needs

Building toward user needs keep us focused on delivering on our mission.

> We always begin with identifying our partners’ needs and the needs of the
> people they serve. Through first-hand research, we explore how to best meet
> those needs. We seek to first understand who we are designing for then figure
> out how to deliver effective solutions. By starting with user needs, we can work
> within our partner’s constraints while also working to change those constraints.

_-- [18F UX Guide](https://github.com/18F/ux-guide/blob/master/README.md)_


### We follow Agile and DevOps methodology

[Agile Manifesto](https://agilemanifesto.org/).

Data.gov follows the four principles of modern [Release
Engineering](https://en.wikipedia.org/wiki/Release_engineering):

* **Identifiability** Being able to identify all of the source, tools,
  environment, and other components that make up a particular release.
* **Reproducibility** The ability to integrate source, third party components,
  data, and deployment externals of a software system in order to guarantee
  operational stability.
* **Consistency** The mission to provide a stable framework for development,
  deployment, audit, and accountability for software components.
* **Agility** The ongoing research into what are the repercussions of modern
  software engineering practices on the productivity in the software cycle, i.e.
  continuous integration.

Additionally, Data.gov is made up of several applications. We strive to maintain
independence of these applications from the underlying Platform.

- Applications follow the [Twelve-Factor Methodology](https://12factor.net).
- The Platform exposes services to applications.
- Deployment of each Application is independent from the deployment of the Platform.


## Sprint rituals

We follow two-week sprints with the following rituals.

- Daily standup (daily)
- Sprint planning (first Monday of the sprint)
- Sprint review and retrospective (last Thursday of the sprint)


## How we track work

We continuously break down larger planned initiatives into **stories**. Stories represent tactical increments of individually-valuable work
deliverable by the team within a single iteration... often an isolated change in
functionality aimed at achieving a goal for a particular kind of stakeholder,
whether customer, user, or operator/admin. 

In addition to planned work, we also track reactive work unrelated to delivering new functionality or capabilities:
* Security or compliance findings
* Flaws in production code
* Support requests requiring technical expertise to resolve
* Onboarding and offboarding procedures

For each of these types of work, a [corresponding template](https://github.com/gsa/data.gov/tree/master/.github/ISSUE_TEMPLATE) provides structure for capturing necessary information. Individual work items are captured in [issues in the `GSA/datagov-deploy` GitHub repository](https://github.com/gsa/data.gov/issues); [creating a new issue in that repository](https://github.com/gsa/data.gov/issues/new/choose) kicks off the process for capturing and prioritizing new work.

The collective set of open issues is visualized as cards on a [Kanban
Board](https://app.zenhub.com/workspaces/datagov-devsecops-579a2532d1d6ea9c3fcf5cfa/board)
and progress through these columns over the course of their existence.

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
- Items are sorted into Product backlog for grooming.


#### Product Backlog

Work sorted by value that we are planning on doing and will groom and schedule into a sprint.

##### Exit criteria

For all kinds of work:
- Any critical information needed to get started on technical work is present.

For stories in particular:
- Indicate the intended benefit and who the story is for in the "as a ..., I want
  ..., so that ..." form.
- Acceptance criteria are defined.
- If necessary, the story includes a security testing plan, and any tasks from
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

#### Blocked

Work that has been started but is blocked by an external party and needs
occasional nudging to get it unblocked.


##### Exit criteria

- Third-party blocker has been removed, the story can move to Sprint backlog or
  In progress.


#### Needs Review

Task has one or more items that need peer review before being merged.


##### Exit criteria

- Work has been reviewed and approved by one or more members of the data.gov team.
- Work is ready to be included on the next release.
- Work has been merged to `master` or `main` branches.


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

Now that applications are moved or are in the process of moving to `cloud.gov`, the `master` branch is in a frozen state and will only capture changes to any application's `fcs` branch.

### Application deployment

All deployments from the `master` branch will capture a frozen state for each application via their `fcs` branch (eg [catalog.data.gov](https://github.com/GSA/catalog.data.gov/tree/fcs)).

Changes to the `master`/`main` should be rare and only include security or compliance updates. The application should be sequentially deployed to sandbox, staging, and then production. If there's an issue with the deploy along
the way, the deploy should be halted and then the issue addressed (following the
usual PR workflow) before starting a new deploy. See [application
release](https://github.com/gsa/data.gov/wiki/Releases#application-release)
for detailed manual deployment steps.


### Platform deployment (datagov-deploy)

We use `master` as the default branch. Any changes are automatically deployed to
the FCS environments after merge by
[CI](https://ci-datagov.mgmt-ocsit.bsp.gsa.gov/). The `develop` branch is
available ad-hoc in order to test changes within the AWS sandbox.

Branch | Deployed to | Frequency
------ | ----------- | ---------
`develop` | AWS sandboxes | On push
`master` | FCS environments | On push

See [Releases](https://github.com/gsa/data.gov/wiki/Releases) for details
on the platform deployment steps.


## Pull requests

Developers should feel empowered to review each others code, even if you're not
an expert on a particular application or feature. Any developer on the team can
review any PR.

What should you do when you review a PR?

- Review the code for quality and consistency
- Call out any breaking changes
- Assert the **Definition of Done** is met
  - Tests are written and running in CI
  - Documentation is written, if applicable
  - Code is in a deployable state

Any critical CI checks should be enforced by GitHub on protected branches
(`master`), so it's not required that CI checks are passing in order to approve
a PR. Instead, it's important that tests have been added and they are running in
CI.

Data.gov encompasses many technologies (too many, in fact) and it's not
practical to have everyone be an expert at everything nor to have only a single
expert review all code in a specific domain e.g. PHP. Any developer should be
able to follow the README in order to get a working system and should post on
the PR if that doesn't seem to be the case.

Ideally, our tests should give us good confidence that changes are working
correctly. Even though that is currently not the case (we are working on
building up our test coverage), it's not required to try out the code locally.

If approved, you may merge immediately or leave it to the author. A single
approval is all that is needed to merge.


[data.gov]: https://github.com/gsa/data.gov
