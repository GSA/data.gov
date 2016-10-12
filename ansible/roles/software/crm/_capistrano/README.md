# CRM Deploy:

## Use the following command(s) to deploy with capistrano: 

- ##### to deploy a specific tag:
`cap {env} deploy branch=release-2014-11-20`

- ##### to deploy a specific branch use:
`cap {env} deploy branch=master`

- ##### to deploy the default branch for each environment use:
`cap {env} deploy`

#### NOTE: 
`{env}` can be  `dev`, `qa`, `uat`, `staging`, `prod-phx`, `prod-phl`
