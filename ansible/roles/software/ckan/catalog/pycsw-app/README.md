# catalog-pycsw-app

This role installs the catalog app harvesters (workers).

## Usage

```yaml
---
- name: install catalog-pycsw-app
  roles:
    - software/ckan/catalog/pycsw-app

### Dependencies

You must install additional requirements.

```yaml
# requirements.yml
---
- src: 'https://github.com/GSA/datagov-deploy-postgresql'
  version: master
  name: gsa.datagov-deploy-postgresql
```
