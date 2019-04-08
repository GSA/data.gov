# catalog-ckan-app

This role installs the catalog app frontend.

## Usage

```yaml
---
- name: install catalog-ckan-app
  roles:
    - software/ckan/catalog/ckan-app
```

### Dependencies

You must install additional requirements.

```yaml
# requirements.yml
---
- src: 'https://github.com/GSA/datagov-deploy-apache2'
  version: master
  name: gsa.datagov-deploy-apache2

- src: 'https://github.com/GSA/datagov-deploy-postgresql'
  version: master
  name: gsa.datagov-deploy-postgresql

- src: 'https://github.com/GSA/datagov-deploy-solr'
  version: master
  name: gsa.datagov-deploy-solr
```