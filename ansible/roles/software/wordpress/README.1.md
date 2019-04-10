# php-crm

 This role installs the crm

 ## Usage

 ```yaml
---
- name: install crm
  roles:
    - software/crm
```

 ### Dependencies

 You must install additional requirements.

 ```yaml
# requirements.yml
---
- src: 'https://github.com/GSA/datagov-deploy-php-common'
  version: master
  name: gsa.datagov-deploy-php-common
 - src: 'https://github.com/GSA/datagov-deploy-mysql'
  version: master
  name: gsa.datagov-deploy-mysql
```
