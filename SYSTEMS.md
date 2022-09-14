
# Systems maintained by Data.gov

## Codebases

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

## Minimum required apps

| App Name                              | Cloud.gov space                                  | Application/Service
|---------------------------------------|--------------------------------------------------|----------------------
| ssb-eks                               | management, management-staging, development-ssb  | SSB-EKS
| ssb-smtp                              | management, management-staging, development-ssb  | SSB-SMTP
| ssb-solrcloud                         | management, management-staging, development-ssb  | SSB-Solr
| logstack-shipper                      | management, management-staging                   | Logstack
| backup-manager                        | development, staging, prod                       | Backup-manager
| catalog-admin                         | development, staging, prod                       | catalog.data.gov
| catalog-proxy                         | development, staging, prod                       | catalog.data.gov
| catalog-fetch                         | development, staging, prod                       | catalog.data.gov
| catalog-gather                        | development, staging, prod                       | catalog.data.gov
| catalog-web                           | development, staging, prod                       | catalog.data.gov
| inventory                             | development, staging, prod                       | inventory.data.gov
| inventory-proxy                       | development, staging, prod                       | inventory.data.gov
| egress-proxy-gsa-datagov-prod         | prod-egress                                      | Egress Proxy (dashboard.data.gov)
| proxy-gsa-datagov-prod-catalog        | prod-egress                                      | Egress Proxy (catalog.data.gov)
| egress-proxy-gsa-datagov-staging      | staging-egress                                   | Egress Proxy (dashboard.data.gov)
| proxy-gsa-datagov-staging-catalog     | staging-egress                                   | Egress Proxy (catalog.data.gov)
| egress-proxy-gsa-datagov-development  | development-egress                               | Egress Proxy (dashboard.data.gov)
| proxy-gsa-datagov-development-catalog | development-egress                               | Egress Proxy (catalog.data.gov)

## Apps to be deprecated

| App Name                  | Cloud.gov space                                  | Application/Service
|---------------------------|--------------------------------------------------|----------------------
| dashboard                 | prod                                             | dashboard.data.gov
| dashboard-dev             | development                                      | dashboard.data.gov
| dashboard-stage           | staging                                          | dashboard.data.gov
| www-redirects             | development, staging, prod                       | Old Static Site

## Minimum services

| Service Name              | Cloud.gov space                                  | Application/Service
|---------------------------|--------------------------------------------------|----------------------
| backup-manager-s3         | development, staging, prod                       | Backup-manager
| datagov-iam               | management, management-staging, development-ssb  | SSB
| terraform-s3              | management                                       | SSB
| logstack-s3               | management, management-staging, development-ssb  | Logstack
| logstack-secrets          | management, management-staging, development-ssb  | Logstack
| ssb-eks-db                | management, management-staging, development-ssb  | SSB-EKS
| ssb-smtp-db               | management, management-staging, development-ssb  | SSB-SMTP
| ssb-solrcloud-db          | management, management-staging, development-ssb  | SSB-Solr
| ssb-solrcloud-k8s         | management, management-staging, development-ssb  | SSB-Solr
| ci-deployer               | ALL SPACES                                       | \*\*Github Actions
| static-site-images        | prod                                             | New Static Site
| sysadmin-users            | development, staging, prod                       | catalog.data.gov, inventory.data.gov
| catalog-db                | development, staging, prod                       | catalog.data.gov
| catalog-redis             | development, staging, prod                       | catalog.data.gov
| catalog-secrets           | development, staging, prod                       | catalog.data.gov
| catalog-smtp              | development, staging, prod                       | catalog.data.gov
| catalog-solr              | development, staging, prod                       | catalog.data.gov
| inventory-cdn             | development, staging, prod                       | inventory.data.gov
| inventory-datastore       | development, staging, prod                       | inventory.data.gov
| inventory-db              | development, staging, prod                       | inventory.data.gov
| inventory-redis           | development, staging, prod                       | inventory.data.gov
| inventory-s3              | development, staging, prod                       | inventory.data.gov
| inventory-solr            | development, staging, prod                       | inventory.data.gov

## Services to be deprecated

| Service Name              | Cloud.gov space                                  | Application/Service
|---------------------------|--------------------------------------------------|----------------------
| dashboard-cdn             | development, staging, prod                       | dashboard.data.gov
| dashboard-db              | development, staging, prod                       | dashboard.data.gov
| dashboard-s3              | development, staging, prod                       | dashboard.data.gov
| dashboard-secrets         | development, staging, prod                       | dashboard.data.gov
| fcs-lifeboat              | prod                                             | \*\*FCS
| www-redirects-domains     | prod                                             | Old Static Site
| ami-scans                 | management                                       | EKS

