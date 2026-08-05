
# Systems maintained by Data.gov

## Codebases

### Primary Codebases

| Application/Service | Repository | Notes |
|---------------------------|------------|-------|
| catalog.data.gov | https://github.com/GSA/datagov-catalog | Current catalog -- custom Python web application |
| harvest.data.gov | https://github.com/GSA/datagov-harvester | Standalone harvest pipeline |
| inventory.data.gov | https://github.com/GSA/inventory-app | CKAN-based -- maintained until reprogrammed off CKAN (target winter 2026) |
| www.data.gov | https://github.com/GSA/datagov-11ty | 
| resources.data.gov | https://github.com/GSA/resources.data.gov | Static site on cloud.gov Pages |
| strategy.data.gov | https://github.com/GSA/data-strategy | Static site on cloud.gov Pages |
| Egress Proxy | https://github.com/GSA/cg-egress-proxy | |
| CKAN User Management | https://github.com/GSA/datagov-account-management | Repo used to help manage account add/update/delete requests for Inventory |
| Logstack | https://github.com/GSA/datagov-logstack | Used to track and send all application logs to various locations |
| Backup-manager | https://github.com/GSA/cf-backup-manager | Application that tracks and maintains backups for database systems for possible restoration point |

### Auxiliary Codebases for inventory (maintained by us for inventory.data.gov and diagrams)

| Application/Service | Repository |
|-------------------------------------------|------------|
| ckanext-datajson | https://github.com/GSA/ckanext-datajson | KEEP |
| ckanext-dcat_usmetadata | https://github.com/GSA/ckanext-dcat_usmetadata | Unk. |
| ckanext-usmetadata | https://github.com/GSA/ckanext-usmetadata | Unk. |
| SSB Compliance Diagrams | https://github.com/GSA/datagov-compliance | KEEP |

### Upstream Codebases (critical to inventory.data.gov and other systems)

| Application/Service | Repository |
|-----------------------------------------------|------------|
| CKAN | https://github.com/GSA/ckan (modified from https://github.com/ckan/ckan), tag ckan-2.11.5-nosolr |
| ckanext-pgsearch | https://github.com/GSA/ckanext-pgsearch |
| ckanext-saml2auth | https://github.com/keitaroinc/ckanext-saml2auth |
| ckanext-xloader | https://github.com/ckan/ckanext-xloader |
| ckanext-envvars | https://github.com/okfn/ckanext-envvars |
| ckanext-s3filestore | https://github.com/keitaroinc/ckanext-s3filestore |
| Python Buildpack | https://github.com/cloudfoundry/python-buildpack |
| NGINX Buildpack | https://github.com/cloudfoundry/nginx-buildpack |
| Cloudfoundry CLI | https://github.com/cloudfoundry/cli |
| Cloud.gov Github Actions CLI | https://github.com/cloud-gov/cg-cli-tools |


## Applications + Services

### Minimum required apps

| App Name                              | Cloud.gov space                                  | Application/Service                   | Deployment Code
|---------------------------------------|--------------------------------------------------|---------------------------------------|---------------------
| logstack-shipper                      | management, management-staging                   | Logstack                              | https://github.com/GSA/datagov-logstack/blob/main/manifest.yml
| backup-manager                        | development, staging, prod                       | Backup-manager                        | https://github.com/GSA/cf-backup-manager/blob/main/manifest.yml
| datagov-harvest-proxy                         | development, staging, prod                       | harvest.data.gov                      | https://github.com/GSA/datagov-harvester/blob/main/manifest.yml @ `((app_name))-proxy`
| datagov-harvest                         | development, staging, prod                       | harvest.data.gov                      | https://github.com/GSA/datagov-harvester/blob/main/manifest.yml @ `((app_name))`
| datagov-catalog-proxy                         | development, staging, prod                       | catalog.data.gov                      | https://github.com/GSA/datagov-catalog/blob/main/manifest.yml @ `((app_name))-proxy`
| datagov-catalog                           | development, staging, prod                       | catalog.data.gov                      | https://github.com/GSA/datagov-catalog/blob/main/manifest.yml @ `((app_name))`
| inventory                             | development, staging, prod                       | inventory.data.gov                    | https://github.com/GSA/inventory-app/blob/main/manifest.yml @ `inventory`
| inventory-proxy                       | development, staging, prod                       | inventory.data.gov                    | ⬆️ @ `inventory-proxy`
| egress-proxy-gsa-datagov-prod         | prod-egress                                      | Egress Proxy (dashboard.data.gov)     | https://github.com/GSA/data.gov/blob/master/.github/workflows/enable-egress.yml

### Apps to be deprecated

| App Name                  | Cloud.gov space                                  | Application/Service
|---------------------------|--------------------------------------------------|----------------------
| www-redirects             | development, staging, prod                       | Old Static Site


### Minimum services

| Service Name              | Cloud.gov space                                  | Application/Service                      | Deployment Code
|---------------------------|--------------------------------------------------|------------------------------------------|----------------------
| backup-manager-s3         | development, staging, prod                       | Backup-manager                           | Manual (See cloud.gov [S3 Docs](https://cloud.gov/docs/services/s3/))
| logstack-s3               | management, management-staging, development-ssb  | Logstack                                 | https://github.com/GSA/datagov-logstack/blob/main/create-cloudgov-services.sh
| logstack-secrets          | management, management-staging, development-ssb  | Logstack                                 | ⬆️
| ci-deployer               | ALL SPACES                                       | \*\*Github Actions                       | Manual (See cloud.gov [Space Deployer Docs](https://cloud.gov/docs/services/cloud-gov-service-account/))
| static-site-images        | prod                                             | New Static Site                          | Manual (See cloud.gov [S3 Docs](https://cloud.gov/docs/services/s3/))
| sysadmin-users            | development, staging, prod                       | catalog.data.gov, inventory.data.gov     | Manual (See cloudfoundry [User-Provided Service Docs](https://docs.cloudfoundry.org/devguide/services/user-provided.html#overview))
| datagov-catalog-db                | development, staging, prod                       | catalog.data.gov                         | https://github.com/GSA/datagov-catalog/blob/main/create-cloudgov-services.sh
| datagov-catalog-opensearch                | development, staging, prod                       | catalog.data.gov                         | https://github.com/GSA/datagov-catalog/blob/main/create-cloudgov-services.sh
| datagov-catalog-secrets           | development, staging, prod                       | catalog.data.gov                         | ⬆️
| datagov-catalog-smtp              | development, staging, prod                       | catalog.data.gov                         | ⬆️
| inventory-secrets             | development, staging, prod                       | inventory.data.gov                       | https://github.com/GSA/inventory-app/blob/main/create-cloudgov-services.sh |
| inventory-datastore       | development, staging, prod                       | inventory.data.gov                       | https://github.com/GSA/inventory-app/blob/main/create-cloudgov-services.sh
| inventory-db              | development, staging, prod                       | inventory.data.gov                       | ⬆️   
| inventory-redis           | development, staging, prod                       | inventory.data.gov                       | ⬆️
| inventory-s3              | development, staging, prod                       | inventory.data.gov                       | ⬆️
