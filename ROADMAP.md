# The [twelve-factor app](http://12factor.net) Checklist

Also factors in the four principles of modern [Release Engineering](https://en.wikipedia.org/wiki/Release_engineering)

* **Identifiability** Being able to identify all of the source, tools, environment, and other components that make up a particular release.
* **Reproducibility** The ability to integrate source, third party components, data, and deployment externals of a software system in order to guarantee operational stability.
* **Consistency** The mission to provide a stable framework for development, deployment, audit, and accountability for software components.
* **Agility** The ongoing research into what are the repercussions of modern software engineering practices on the productivity in the software cycle, i.e. continuous integration.

## [Codebase](http://12factor.net/codebase)
One codebase tracked in revision control, many deploys
> The Version Control system manages past, present, and proposed versions as branches
- [ ] 1 code base for an `app`, no code is shared or dependent on code from any other `app`?
- [ ] 1 code repository is used to managed all releases/versions?

## [Dependencies](http://12factor.net/dependencies)
Explicitly declare and isolate dependencies
> All required dependencies either use a community package manager or are managed from source are managed in a permissioned version control system.
- [ ] the `app` does not rely on common/system-wide packages (ex. apt-get/yum)
- [ ] the `app` installs within an isolated or virtualized environment where version of the code engine (python/ruby/node) are explicitly controlled/declared in addition to its required libraries/dependencies (*if applicable)

Ruby
* Gemfile
Node
* package.json
Python
* requirements.txt
Makefile
Maven


## [Config](http://12factor.net/config)
All system/service configuration is stored in a separate and secure environment
> The app stores config in environment variables that are easy to change between
deploys without changing any code. They are never grouped together as
 "environments" (does not scale), but instead are independently managed
for each deploy.
- [ ] Configuration is seperated from codebase
- [ ] Configuration is managed entirely by variables that can be changed/established on build
- [ ] Production Config files are managed in a private repository with 2-factor auth or managed as prompts
- [ ] Production Config files are included in .gitignore

## [Backing Services](http://12factor.net/backing-services)
Treat backing services (DB/Messaging/SearchIndexing/Email/etc) as external attached resources
> The code for an app makes no distinction between local and third party services.
- [ ] Item 1
- [ ] Item 2

## [Build, Release, Run](http://12factor.net/build-release-run)
> Strictly separate build and run stages
- [ ] Item 1
- [ ] Item 2

## Processes
Execute the app as one or more stateless processes
> Processes are stateless and share-nothing. Any data that needs to persist must
be stored in a stateful backing service, typically a database.
Sticky sessions are a violation and should never be used or relied upon.
- [ ] Item 1
- [ ] Item 2

## Port binding
-----------------
Export services via port binding
> Ensure build scripts denote all ports/users
- [ ] Item 1
- [ ] Item 2

## Concurrency
Scale out via the process model
> Blah
- [ ] Item 1
- [ ] Item 2

## Disposability
Maximize robustness with fast startup and graceful shutdown
> Blah
- [ ] Item 1
- [ ] Item 2

## Dev/prod parity
Keep development, staging, and production as similar as possible

> Make the following gap as small as possible:
* The time gap: Time between writing code and deploy of it.
* The personell gap: Developers write code, ops deploy it.
* The tools gap: Development and production tools.
- [ ] Item 1
- [ ] Item 2

## Logs
Treat logs as events streams
> The app never concerns itself with routing or storage of its output.
- [ ] Item 1
- [ ] Item 2

- [ ] ## Admin processes
Run admin/management tasks as one-off processes
> Blah
- [ ] Item 1
- [ ] Item 2
