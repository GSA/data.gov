## Draft SYSTEMS.md content for PR

The following is a proposed replacement for SYSTEMS.md. Rows marked ⚠️ VERIFY need confirmation before merging.

---

# Systems maintained by Data.gov

## Codebases

### Primary Codebases

| Application/Service | Repository | Notes |
|---------------------------|------------|-------|
| catalog.data.gov | https://github.com/GSA/datagov-catalog | Current catalog -- custom Python web application |
| catalog.data.gov (legacy) | https://github.com/GSA/catalog.data.gov | Legacy CKAN catalog at catalog-old.data.gov -- maintained through fall 2026 |
| harvest.data.gov | https://github.com/GSA/datagov-harvester | Standalone harvest pipeline |
| inventory.data.gov | https://github.com/GSA/inventory-app | CKAN-based -- maintained until reprogrammed off CKAN (target fall 2026) |
| www.data.gov | https://github.com/GSA/datagov-11ty | 
| resources.data.gov | https://github.com/GSA/resources.data.gov | Static site on cloud.gov Pages |
| strategy.data.gov | https://github.com/GSA/data-strategy | Static site on cloud.gov Pages |
| Egress Proxy | https://github.com/GSA/cg-egress-proxy | |
| CKAN User Management | https://github.com/GSA/datagov-account-management | Repo used to help manage account add/update/delete requests for Inventory/Catalog |
| Logstack | https://github.com/GSA/datagov-logstack | ⚠️ VERIFY: confirm still in active use |
| SSB | https://github.com/GSA/datagov-ssb | ⚠️ VERIFY: confirm still in use post-catalog migration |
| Solr | https://github.com/GSA-TTS/datagov-brokerpak-solr | ⚠️ VERIFY: Solr now on separate AWS instance for inventory -- confirm if brokerpak still applies |
| Backup-manager | https://github.com/GSA/cf-backup-manager | ⚠️ VERIFY: confirm still in active use |

### Auxiliary Codebases (maintained by us for inventory.data.gov)

⚠️ VERIFY: Confirm which of the following CKAN extensions are still actively maintained for inventory.data.gov. Move any that are no longer maintained to Deprecated.

| Application/Service | Repository |
|-------------------------------------------|------------|
| ckanext-datagovcatalog | https://github.com/GSA/ckanext-datagovcatalog | OLD |
| ckanext-datagovtheme | https://github.com/GSA/ckanext-datagovtheme | OLD |
| ckanext-datajson | https://github.com/GSA/ckanext-datajson | KEEP |
| ckanext-geodatagov | https://github.com/GSA/ckanext-geodatagov | OLD |
| ckanext-googleanalyticsbasic | https://github.com/GSA/ckanext-googleanalyticsbasic | OLD |
| ckanext-qa | https://github.com/GSA/ckanext-qa | OLD |
| ckanext-dcat_usmetadata | https://github.com/GSA/ckanext-dcat_usmetadata | Unk. |
| ckanext-usmetadata | https://github.com/GSA/ckanext-usmetadata | Unk. |
| SSB Compliance Diagrams | https://github.com/GSA/datagov-compliance | KEEP |

### Upstream Codebases (critical to inventory.data.gov)

| Application/Service | Repository |
|-----------------------------------------------|------------|
| CKAN | https://github.com/ckan/ckan |
| ckanext-dcat | https://github.com/ckan/ckanext-dcat |
| ckanext-harvest | https://github.com/ckan/ckanext-harvest |
| ckanext-saml2auth | https://github.com/keitaroinc/ckanext-saml2auth |
| ckanext-report | https://github.com/ckan/ckanext-report |
| ckanext-archiver | https://github.com/ckan/ckanext-archiver |
| ckanext-xloader | https://github.com/ckan/ckanext-xloader |
| ckanext-envvars | https://github.com/okfn/ckanext-envvars |
| Cloud Service Broker (production) | https://github.com/cloudfoundry/cloud-service-broker |
| AWS Broker (all cloud.gov AWS-based services) | https://github.com/cloud-gov/aws-broker |
| Python Buildpack | https://github.com/cloudfoundry/python-buildpack |
| Apt Buildpack | https://github.com/cloudfoundry/apt-buildpack |
| NGINX Buildpack | https://github.com/cloudfoundry/nginx-buildpack |
| Cloudfoundry CLI | https://github.com/cloudfoundry/cli |
| Cloud.gov Github Actions CLI | https://github.com/cloud-gov/cg-cli-tools |


## Applications + Services

### Minimum required apps

| App Name                              | Cloud.gov space                                  | Application/Service                   | Deployment Code
|---------------------------------------|--------------------------------------------------|---------------------------------------|---------------------
| ssb-eks                               | management, management-staging, development-ssb  | SSB-EKS                               | https://github.com/GSA/datagov-ssb/blob/main/application-boundary.tf @ `broker_eks`
| ssb-smtp                              | management, management-staging, development-ssb  | SSB-SMTP                              | ⬆️ @ `broker_smtp`
| ssb-solrcloud                         | management, management-staging, development-ssb  | SSB-Solr                              | ⬆️ @ `broker_solrcloud`
| logstack-shipper                      | management, management-staging                   | Logstack                              | https://github.com/GSA/datagov-logstack/blob/main/manifest.yml
| backup-manager                        | development, staging, prod                       | Backup-manager                        | https://github.com/GSA/cf-backup-manager/blob/main/manifest.yml
| catalog-admin                         | development, staging, prod                       | catalog.data.gov                      | https://github.com/GSA/datagov-catalog/blob/main/manifest.yml @ `catalog-admin`
| catalog-proxy                         | development, staging, prod                       | catalog.data.gov                      | ⬆️ @ `catalog-proxy`
| catalog-fetch                         | development, staging, prod                       | catalog.data.gov                      | ⬆️ @ `catalog-fetch`
| catalog-gather                        | development, staging, prod                       | catalog.data.gov                      | ⬆️ @ `catalog-gather`
| catalog-web                           | development, staging, prod                       | catalog.data.gov                      | ⬆️ @ `catalog-web`
| inventory                             | development, staging, prod                       | inventory.data.gov                    | https://github.com/GSA/inventory-app/blob/main/manifest.yml @ `inventory`
| inventory-proxy                       | development, staging, prod                       | inventory.data.gov                    | ⬆️ @ `inventory-proxy`
| egress-proxy-gsa-datagov-prod         | prod-egress                                      | Egress Proxy (dashboard.data.gov)     | https://github.com/GSA/data.gov/blob/master/.github/workflows/enable-egress.yml
| proxy-gsa-datagov-prod-catalog        | prod-egress                                      | Egress Proxy (catalog.data.gov)
| egress-proxy-gsa-datagov-staging      | staging-egress                                   | Egress Proxy (dashboard.data.gov)
| proxy-gsa-datagov-staging-catalog     | staging-egress                                   | Egress Proxy (catalog.data.gov)
| egress-proxy-gsa-datagov-development  | development-egress                               | Egress Proxy (dashboard.data.gov)
| proxy-gsa-datagov-development-catalog | development-egress                               | Egress Proxy (catalog.data.gov)

### Apps to be deprecated

| App Name                  | Cloud.gov space                                  | Application/Service
|---------------------------|--------------------------------------------------|----------------------
| www-redirects             | development, staging, prod                       | Old Static Site

| App Name | Cloud.gov space | Application/Service | Deployment Code |
|---------------------------------------|-----------------|---------------------|-----------------|
| inventory | development, staging, prod | inventory.data.gov | https://github.com/GSA/inventory-app/blob/main/manifest.yml |
| inventory-proxy | development, staging, prod | inventory.data.gov | ⬆️ |
| egress-proxy-gsa-datagov-prod | prod-egress | Egress Proxy | https://github.com/GSA/data.gov/blob/master/.github/workflows/enable-egress.yml |
| backup-manager | development, staging, prod | Backup-manager | https://github.com/GSA/cf-backup-manager/blob/main/manifest.yml |
| ⚠️ VERIFY | | catalog.data.gov (datagov-catalog) | Add current app names from datagov-catalog manifest |
| ⚠️ VERIFY | | harvest.data.gov (datagov-harvester) | Add current app names from datagov-harvester manifest |


### Minimum services

| Service Name              | Cloud.gov space                                  | Application/Service                      | Deployment Code
|---------------------------|--------------------------------------------------|------------------------------------------|----------------------
| backup-manager-s3         | development, staging, prod                       | Backup-manager                           | Manual (See cloud.gov [S3 Docs](https://cloud.gov/docs/services/s3/))
| datagov-iam               | management, management-staging, development-ssb  | SSB                                      | (not sure)
| terraform-s3              | management                                       | SSB                                      | Manual (NEVER DELETE) (See cloud.gov [S3 Docs](https://cloud.gov/docs/services/s3/))
| logstack-s3               | management, management-staging, development-ssb  | Logstack                                 | https://github.com/GSA/datagov-logstack/blob/main/create-cloudgov-services.sh
| logstack-secrets          | management, management-staging, development-ssb  | Logstack                                 | ⬆️
| ssb-eks-db                | management, management-staging, development-ssb  | SSB-EKS                                  | https://github.com/GSA/datagov-ssb/blob/main/broker/main.tf @ `cloudfoundry_service_instance.db`
| ssb-smtp-db               | management, management-staging, development-ssb  | SSB-SMTP                                 | ⬆️
| ssb-solrcloud-db          | management, management-staging, development-ssb  | SSB-Solr                                 | ⬆️
| ssb-solrcloud-k8s         | management, management-staging, development-ssb  | SSB-Solr                                 | https://github.com/GSA/datagov-ssb/blob/main/application-boundary.tf @ `cloudfoundry_service_instance.solrcloud_broker_k8s_cluster`
| ci-deployer               | ALL SPACES                                       | \*\*Github Actions                       | Manual (See cloud.gov [Space Deployer Docs](https://cloud.gov/docs/services/cloud-gov-service-account/))
| static-site-images        | prod                                             | New Static Site                          | Manual (See cloud.gov [S3 Docs](https://cloud.gov/docs/services/s3/))
| sysadmin-users            | development, staging, prod                       | catalog.data.gov, inventory.data.gov     | Manual (See cloudfoundry [User-Provided Service Docs](https://docs.cloudfoundry.org/devguide/services/user-provided.html#overview))
| catalog-db                | development, staging, prod                       | catalog.data.gov                         | https://github.com/GSA/datagov-catalog/blob/main/create-cloudgov-services.sh
| catalog-redis             | development, staging, prod                       | catalog.data.gov                         | ⬆️
| catalog-secrets           | development, staging, prod                       | catalog.data.gov                         | ⬆️
| catalog-smtp              | development, staging, prod                       | catalog.data.gov                         | ⬆️
| catalog-solr              | development, staging, prod                       | catalog.data.gov                         | ⬆️
| inventory-cdn             | development, staging, prod                       | inventory.data.gov                       | Manual (See cloud.gov [External Domain Docs](https://cloud.gov/docs/services/external-domain-service/))
| inventory-datastore       | development, staging, prod                       | inventory.data.gov                       | https://github.com/GSA/inventory-app/blob/main/create-cloudgov-services.sh
| inventory-db              | development, staging, prod                       | inventory.data.gov                       | ⬆️   
| inventory-redis           | development, staging, prod                       | inventory.data.gov                       | ⬆️
| inventory-s3              | development, staging, prod                       | inventory.data.gov                       | ⬆️
| inventory-solr            | development, staging, prod                       | inventory.data.gov                       | ⬆️

### Services to be deprecated

| Service Name              | Cloud.gov space                                  | Application/Service
|---------------------------|--------------------------------------------------|----------------------
| dashboard-cdn             | development, staging, prod                       | dashboard.data.gov
| dashboard-db              | development, staging, prod                       | dashboard.data.gov
| dashboard-s3              | development, staging, prod                       | dashboard.data.gov
| dashboard-secrets         | development, staging, prod                       | dashboard.data.gov
| fcs-lifeboat              | prod                                             | \*\*FCS
| www-redirects-domains     | prod                                             | Old Static Site
| ami-scans                 | management                                       | EKS

⚠️ VERIFY: Remove catalog-solr and inventory-solr if Solr is now on a separate AWS instance rather than cloud.gov. Confirm which services below are still current.

| Service Name | Cloud.gov space | Application/Service |
|---------------------------|-----------------|---------------------|
| backup-manager-s3 | development, staging, prod | Backup-manager |
| ci-deployer | ALL SPACES | Github Actions |
| inventory-cdn | development, staging, prod | inventory.data.gov |
| inventory-datastore | development, staging, prod | inventory.data.gov |
| inventory-db | development, staging, prod | inventory.data.gov |
| inventory-redis | development, staging, prod | inventory.data.gov |
| inventory-s3 | development, staging, prod | inventory.data.gov |
| inventory-solr | development, staging, prod | inventory.data.gov |
| sysadmin-users | development, staging, prod | inventory.data.gov |
| ⚠️ VERIFY | | catalog.data.gov services -- add from datagov-catalog manifest |
| ⚠️ VERIFY | | harvest.data.gov services -- add from datagov-harvester manifest |
