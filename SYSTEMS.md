
# Systems maintained by Data.gov

## Codebases

### Primary Codebases

| Application/Service       | Repository 
|---------------------------|-----------
| catalog.data.gov          | https://github.com/GSA/catalog.data.gov
| inventory.data.gov        | https://github.com/GSA/inventory-app/
| dashboard.data.gov        | https://github.com/GSA/project-open-data-dashboard/
| SSB                       | https://github.com/GSA/datagov-ssb/
| Solr                      | https://github.com/GSA/datagov-brokerpak-solr
| SMTP                      | https://github.com/GSA/datagov-brokerpak-smtp
| EKS                       | https://github.com/GSA/datagov-brokerpak-eks
| Logstack                  | https://github.com/GSA/datagov-logstack/
| Backup-manager            | https://github.com/GSA/cf-backup-manager
| Old Static Site           | https://github.com/GSA/datagov-website/
| New Static Site           | https://github.com/GSA/datagov-11ty/
| Egress Proxy              | https://github.com/GSA/cg-egress-proxy

### Auxilary Codebases (also maintained by us)

| Application/Service                       | Repository 
|-------------------------------------------|-----------
| Cloud Service Broker (development)        | https://github.com/GSA/cloud-service-broker
| ckanext-datagovcatalog                    | https://github.com/GSA/ckanext-datagovcatalog
| ckanext-datagovtheme                      | https://github.com/GSA/ckanext-datagovtheme
| ckanext-datajson                          | https://github.com/GSA/ckanext-datajson
| ckanext-geodatagov                        | https://github.com/GSA/ckanext-geodatagov
| ckanext-googleanalyticsbasic              | https://github.com/GSA/ckanext-googleanalyticsbasic
| ckanext-qa                                | https://github.com/GSA/ckanext-qa
| ckanext-dcat_usmetadata                   | https://github.com/GSA/ckanext-dcat_usmetadata
| ckanext-usmetadata                        | https://github.com/GSA/ckanext-usmetadata
| dedupe (harvesting)                       | https://github.com/GSA/datagov-dedupe
| SSB Compliance Diagrams                   | https://github.com/GSA/datagov-compliance
| Load testing software                     | https://github.com/GSA/datagov-load-testing

### Upstream Codebases (critical to our applications)

| Application/Service                           | Repository 
|-----------------------------------------------|-----------
| CKAN                                          | https://github.com/ckan/ckan
| ckanext-dcat                                  | https://github.com/ckan/ckanext-dcat
| ckanext-harvest                               | https://github.com/ckan/ckanext-harvest
| ckanext-saml2auth                             | https://github.com/keitaroinc/ckanext-saml2auth
| ckanext-report                                | https://github.com/ckan/ckanext-report
| ckanext-archiver                              | https://github.com/ckan/ckanext-archiver
| PyZ3950                                       | https://github.com/asl2/PyZ3950
| ckanext-xloader                               | https://github.com/ckan/ckanext-xloader
| ckanext-envvars                               | https://github.com/okfn/ckanext-envvars
| docker-ckan (development)                     | https://github.com/okfn/docker-ckan
| Cloud Service Broker (production)             | https://github.com/cloudfoundry/cloud-service-broker
| AWS Broker (all cloud.gov AWS-based services) | https://github.com/cloud-gov/aws-broker
| Python Buildpack                              | https://github.com/cloudfoundry/python-buildpack
| Apt Buildpack                                 | https://github.com/cloudfoundry/apt-buildpack
| NGINX Buildpack                               | https://github.com/cloudfoundry/nginx-buildpack
| Cloudfoundry CLI                              | https://github.com/cloudfoundry/cli
| Cloud.gov Github Actions CLI                  | https://github.com/cloud-gov/cg-cli-tools
| SSB Github Action Terraform Deploy            | https://github.com/dflook/terraform-github-actions

## Applications + Services

### Minimum required apps

| App Name                              | Cloud.gov space                                  | Application/Service                   | Deployment Code
|---------------------------------------|--------------------------------------------------|---------------------------------------|---------------------
| ssb-eks                               | management, management-staging, development-ssb  | SSB-EKS                               | https://github.com/GSA/datagov-ssb/blob/main/application-boundary.tf @ `broker_eks`
| ssb-smtp                              | management, management-staging, development-ssb  | SSB-SMTP                              | ⬆️ @ `broker_smtp`
| ssb-solrcloud                         | management, management-staging, development-ssb  | SSB-Solr                              | ⬆️ @ `broker_solrcloud`
| logstack-shipper                      | management, management-staging                   | Logstack                              | https://github.com/GSA/datagov-logstack/blob/main/manifest.yml
| backup-manager                        | development, staging, prod                       | Backup-manager                        | https://github.com/GSA/cf-backup-manager/blob/main/manifest.yml
| catalog-admin                         | development, staging, prod                       | catalog.data.gov                      | https://github.com/GSA/catalog.data.gov/blob/main/manifest.yml @ `catalog-admin`
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
| dashboard                 | prod                                             | dashboard.data.gov
| dashboard-dev             | development                                      | dashboard.data.gov
| dashboard-stage           | staging                                          | dashboard.data.gov
| www-redirects             | development, staging, prod                       | Old Static Site

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
| catalog-db                | development, staging, prod                       | catalog.data.gov                         | https://github.com/GSA/catalog.data.gov/blob/main/create-cloudgov-services.sh
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

