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
| www.data.gov | https://github.com/GSA/datagov-website | ⚠️ VERIFY: confirm this is still the correct repo for www.data.gov |
| resources.data.gov | https://github.com/GSA/resources.data.gov | Static site on cloud.gov Pages |
| strategy.data.gov | https://github.com/GSA/data-strategy | Static site on cloud.gov Pages |
| Egress Proxy | https://github.com/GSA/cg-egress-proxy | |
| CKAN User Management | https://github.com/GSA/datagov-account-management | |
| Logstack | https://github.com/GSA/datagov-logstack | ⚠️ VERIFY: confirm still in active use |
| SSB | https://github.com/GSA/datagov-ssb | ⚠️ VERIFY: confirm still in use post-catalog migration |
| Solr | https://github.com/GSA-TTS/datagov-brokerpak-solr | ⚠️ VERIFY: Solr now on separate AWS instance for inventory -- confirm if brokerpak still applies |
| Backup-manager | https://github.com/GSA/cf-backup-manager | ⚠️ VERIFY: confirm still in active use |

### Auxiliary Codebases (maintained by us for inventory.data.gov)

⚠️ VERIFY: Confirm which of the following CKAN extensions are still actively maintained for inventory.data.gov. Move any that are no longer maintained to Deprecated.

| Application/Service | Repository |
|-------------------------------------------|------------|
| ckanext-datagovcatalog | https://github.com/GSA/ckanext-datagovcatalog |
| ckanext-datagovtheme | https://github.com/GSA/ckanext-datagovtheme |
| ckanext-datajson | https://github.com/GSA/ckanext-datajson |
| ckanext-geodatagov | https://github.com/GSA/ckanext-geodatagov |
| ckanext-googleanalyticsbasic | https://github.com/GSA/ckanext-googleanalyticsbasic |
| ckanext-qa | https://github.com/GSA/ckanext-qa |
| ckanext-dcat_usmetadata | https://github.com/GSA/ckanext-dcat_usmetadata |
| ckanext-usmetadata | https://github.com/GSA/ckanext-usmetadata |
| SSB Compliance Diagrams | https://github.com/GSA/datagov-compliance |

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

### Deprecated Codebases

| Application/Service | Repository |
|-------------------------------------------|------------|
| dashboard.data.gov | https://github.com/GSA/project-open-data-dashboard |
| Old Static Site (WordPress) | https://github.com/GSA/datagov-website |
| datagov-11ty | https://github.com/GSA/datagov-11ty |
| Cloud Service Broker (development) | https://github.com/GSA/cloud-service-broker |
| datagov-harvesting-logic | https://github.com/GSA/datagov-harvesting-logic |
| dedupe (harvesting) | https://github.com/GSA/datagov-dedupe |
| Load testing software | https://github.com/GSA/datagov-load-testing |
| Terraform ALB Controller | https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller |
| EKS | https://github.com/GSA-TTS/datagov-brokerpak-eks |
| SMTP | https://github.com/GSA-TTS/datagov-brokerpak-smtp |

## Applications + Services

### Minimum required apps

⚠️ VERIFY: The apps table below needs a full review. The CKAN-era app names (catalog-admin, catalog-web, catalog-fetch, catalog-gather, catalog-proxy) are no longer valid for the current catalog. Replace with current datagov-catalog app names and add datagov-harvester app names.

| App Name | Cloud.gov space | Application/Service | Deployment Code |
|---------------------------------------|-----------------|---------------------|-----------------|
| inventory | development, staging, prod | inventory.data.gov | https://github.com/GSA/inventory-app/blob/main/manifest.yml |
| inventory-proxy | development, staging, prod | inventory.data.gov | ⬆️ |
| egress-proxy-gsa-datagov-prod | prod-egress | Egress Proxy | https://github.com/GSA/data.gov/blob/master/.github/workflows/enable-egress.yml |
| backup-manager | development, staging, prod | Backup-manager | https://github.com/GSA/cf-backup-manager/blob/main/manifest.yml |
| ⚠️ VERIFY | | catalog.data.gov (datagov-catalog) | Add current app names from datagov-catalog manifest |
| ⚠️ VERIFY | | harvest.data.gov (datagov-harvester) | Add current app names from datagov-harvester manifest |

### Minimum services

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
