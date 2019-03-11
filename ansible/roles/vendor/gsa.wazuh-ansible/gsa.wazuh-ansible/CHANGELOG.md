# Change Log
All notable changes to this project will be documented in this file.

## [v3.8.1]

### Changed 
- Update to Wazuh version v3.8.1. ([#148](https://github.com/wazuh/wazuh-ansible/pull/148))

## [v3.8.0]

### Added

- Added custom name for single agent registration ([#117](https://github.com/wazuh/wazuh-ansible/pull/117))
- Adapt ossec.conf file for windows agents ([#118](https://github.com/wazuh/wazuh-ansible/pull/118))
- Added labels to ossec.conf ([#135](https://github.com/wazuh/wazuh-ansible/pull/135))

### Changed 

- Changed Windows installation directory ([#116](https://github.com/wazuh/wazuh-ansible/pull/116))
- move redundant tags to the outer block ([#133](https://github.com/wazuh/wazuh-ansible/pull/133))
- Adapt new version (3.8.0-6.5.4) ([#144](https://github.com/wazuh/wazuh-ansible/pull/144))

### Fixed

- Fixed a couple linting issues with yamllint and ansible-review ([#111](https://github.com/wazuh/wazuh-ansible/pull/111))
- Fixes typos: The word credentials doesn't have two consecutive e's ([#130](https://github.com/wazuh/wazuh-ansible/pull/130))
- Fixed multiple remote connection ([#120](https://github.com/wazuh/wazuh-ansible/pull/120))
- Fixed null value for wazuh_manager_fqdn ([#132](https://github.com/wazuh/wazuh-ansible/pull/132))
- Erasing extra spaces in playbooks ([#131](https://github.com/wazuh/wazuh-ansible/pull/131))
- Fixed oracle java cookies ([#143](https://github.com/wazuh/wazuh-ansible/pull/143))

### Removed

- delete useless files from wazuh-manager role ([#137](https://github.com/wazuh/wazuh-ansible/pull/137))

## [v3.7.2]

### Changed

- Adapt configuration to current release ([#106](https://github.com/wazuh/wazuh-ansible/pull/106))

## [v3.7.1]

### Added

 - include template local_internal_options.conf. ([#87](https://github.com/wazuh/wazuh-ansible/pull/87))
 - Add multiple Elasticsearch IPs for Logstash reports. ([#92](https://github.com/wazuh/wazuh-ansible/pull/92))

### Changed

 - Changed windows agent version. ([#89](https://github.com/wazuh/wazuh-ansible/pull/89))
 - Updating to Elastic Stack to 6.5.3 and Wazuh 3.7.1. ([#108](https://github.com/wazuh/wazuh-ansible/pull/108))
 
### Fixed

- Solve the conflict betwwen tha agent configuration and the shared master configuration. Also include monitoring for `/var/log/auth.log`. ([#90](https://github.com/wazuh/wazuh-ansible/pull/90))
- Moved custom_ruleset files. ([#98](https://github.com/wazuh/wazuh-ansible/pull/98))
- Add authlog fix to localfile. ([#99](https://github.com/wazuh/wazuh-ansible/pull/99))
- Exceptions reload systemd. ([#114](https://github.com/wazuh/wazuh-ansible/pull/114))

### Removed

- clean old code for windows agent. ([#86](https://github.com/wazuh/wazuh-ansible/pull/86))

## v3.7.0-3701

### Added

- Amazon Linux deployments are now supported ([#71](https://github.com/wazuh/wazuh-ansible/pull/71)) and for the old repository structure ([#67](https://github.com/wazuh/wazuh-ansible/pull/67))
- Added the option to add rule files and decoders directly over the local rule and decoder directories in /var/ossec/etc ([#81](https://github.com/wazuh/wazuh-ansible/pull/81)).
- Added the necessary variables to configure a new configuration template for the Wazuh API ([#80](https://github.com/wazuh/wazuh-ansible/pull/80)).
- Added the option to verify the shared configuration for agents set in the manager ([#76](https://github.com/wazuh/wazuh-ansible/pull/76)).
- Added the option to configure the active response ([#75](https://github.com/wazuh/wazuh-ansible/pull/75)).

### Changed

- Repository restructure.
- Extended conditions to register a Wazuh agent. Now will register the agent in cases where there is no client.keys or the file exists but this empty ([#79](https://github.com/wazuh/wazuh-ansible/pull/79)).
- Grouping of tasks in a block under the same condition to improve the efficiency of the code ([#74](https://github.com/wazuh/wazuh-ansible/pull/74)).
- Improved efficiency of the Java repository ([#73](https://github.com/wazuh/wazuh-ansible/pull/73)).

### Fixed

- Fix oracle java cookie ([#71](https://github.com/wazuh/wazuh-ansible/pull/71)).
- include the logall_json label in ossec.conf template. This was causing an error when recreating the cdb_lists ([#84](https://github.com/wazuh/wazuh-ansible/pull/84)).

## v3.6.0

Ansible starting point.

Roles:
 - Elastic Stack:
   - ansible-elasticsearch: This role is prepared to install elasticsearch on the host that runs it.
   - ansible-logstash: This role involves the installation of logstash on the host that runs it.
   - ansible-kibana: Using this role we will install Kibana on the host that runs it.
 - Wazuh:
   - ansible-filebeat: This role is prepared to install filebeat on the host that runs it.
   - ansible-wazuh-manager: With this role we will install Wazuh manager and Wazuh API on the host that runs it.
   - ansible-wazuh-agent: Using this role we will install Wazuh agent on the host that runs it and is able to register it.

