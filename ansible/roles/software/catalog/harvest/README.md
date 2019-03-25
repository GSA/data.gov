# catalog-harvest

This role installs the catalog app harvesters (workers).

## Usage

```yaml
---
- name: install catalog-harvester
  roles:
    - software/catalog/harvest
```

### Dependencies

You must install additional requirements.

```yaml
# requirements.yml
---
- src: 'https://github.com/GSA/datagov-deploy-redis'
  version: master
  name: gsa.datagov-deploy-redis
```
