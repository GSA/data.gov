# CI

Configures a host to automatically run the ansible playbooks and log the
results. This is used in firewalled environments where third-party CI solution
is unavailable.


## Requirements

N/A


## Role variables

**ci_inventory** string **required**

The ansible inventory to run the CI script against.

**ci_username** string

The Linux user account to create for running the CI script.

**ci_home_dir** string

Home directory for the CI user.

**ci_log_dir** string

The directory to log to. You may want to configure logrotate for /var/log/ci.log
to avoid the file growing too large.


## Dependencies

- [geerlingguy.git](https://galaxy.ansible.com/geerlingguy/git) role


## Example playbook

```yaml
---
- hosts: jumpbox
  roles:
     - role: ci
```


## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
