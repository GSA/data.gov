# Unattended-Upgrades Role for Ansible

[![Build Status of branch master](https://img.shields.io/travis/jnv/ansible-role-unattended-upgrades/master.svg?style=flat-square)](https://travis-ci.org/jnv/ansible-role-unattended-upgrades)
[![Ansible Role: jnv.unattended-upgrades](https://img.shields.io/ansible/role/8068.svg?style=flat-square)](https://galaxy.ansible.com/jnv/unattended-upgrades/)

Install and setup [unattended-upgrades](https://launchpad.net/unattended-upgrades) for Ubuntu and Debian (since Wheezy), to periodically install security upgrades.

**NOTE:** If you have used version 0.0.1 of the role, you can delete the file `/etc/apt/apt.conf.d/10periodic` as it is not needed anymore. You can use the following one-shot command:

    ansible -m file -a "state=absent path=/etc/apt/apt.conf.d/10periodic" <host-pattern>

## Requirements

The role uses [apt module](http://docs.ansible.com/apt_repository_module.html) which has additional dependencies.

If you set `unattended_mail` to an e-mail address, make sure `mailx` command is available and your system is able to send e-mails.

The role requires unattended-upgrades version 0.70 and newer, which is available since Debian Wheezy and Ubuntu 12.04 respectively. This is due to [Origins Patterns](#origins-patterns) usage; if this is not available on your system, you may use [the first version of the role](https://github.com/jnv/ansible-role-unattended-upgrades/tree/v0.1).

### Automatic Reboot

If you enable automatic reboot feature (`unattended_automatic_reboot`), the role will attempt to install `update-notifier-common` package, which is required on some systems for detecting and executing reboot after the upgrade. You may optionally define a specific time for rebooting (`unattended_automatic_reboot_time`).

This feature was broken in Debian Jessie, but eventually was rolled into the unattended-upgrades package; see [the discussion in #6](https://github.com/jnv/ansible-role-unattended-upgrades/issues/6) for more details.

## Disabled Cron Jobs

On some hosts you may find that the unattended-upgrade's cronfile `/etc/cron.daily/apt` file has been renamed to `apt.disabled`. This is possibly provider's decision, to save some CPU cycles. Use [enable-standard-cronjobs](https://github.com/Yannik/ansible-role-enable-standard-cronjobs) role to reenable unattended-upgrades. See also discussion in [#9](https://github.com/jnv/ansible-role-unattended-upgrades/issues/9).

## Role Variables

* `unattended_cache_valid_time`: Update the apt cache if its older than the given time in seconds; passed to the [apt module](https://docs.ansible.com/ansible/latest/apt_module.html) during package installation.
    * Default: `3600`
* `unattended_origins_patterns`: array of origins patterns to determine whether the package can be automatically installed, for more details see [Origins Patterns](#origins-patterns) below.
    * Default for Debian: `['origin=Debian,codename=${distro_codename},label=Debian-Security']`
    * Default for Ubuntu: `['origin=Ubuntu,archive=${distro_codename}-security,label=Ubuntu']`
* `unattended_package_blacklist`: packages which won't be automatically upgraded
    * Default: `[]`
* `unattended_autofix_interrupted_dpkg`: whether on unclean dpkg exit to run `dpkg --force-confold --configure -a`
    * Default: `true`
* `unattended_minimal_steps`: split the upgrade into the smallest possible chunks so that they can be interrupted with SIGUSR1.
    * Default: `false`
* `unattended_install_on_shutdown`: install all unattended-upgrades when the machine is shuting down.
    * Default: `false`
* `unattended_mail`: e-mail address to send information about upgrades or problems with unattended upgrades
    * Default: `false` (don't send any e-mail)
* `unattended_mail_only_on_error`: send e-mail only on errors, otherwise e-mail will be sent every time there's a package upgrade.
    * Default: `false`
* `unattended_remove_unused_dependencies`: do automatic removal of new unused dependencies after the upgrade.
    * Default: `false`
* `unattended_automatic_reboot`: Automatically reboot system if any upgraded package requires it, immediately after the upgrade.
    * Default: `false`
* `unattended_automatic_reboot_time`: Automatically reboot system if any upgraded package requires it, at the specific time (_HH:MM_) instead of immediately after the upgrade.
    * Default: `false`
* `unattended_update_days`: Set the days of the week that updates should be applied. The days can be specified as localized abbreviated or full names. Or as integers where "0" is Sunday, "1" is Monday etc. Example: `{"Mon";"Fri"};`
    * Default: disabled
* `unattended_ignore_apps_require_restart`: unattended-upgrades won't automatically upgrade some critical packages requiring restart after an upgrade (i.e. there is `XB-Upgrade-Requires: app-restart` directive in their debian/control file). With this option set to `true`, unattended-upgrades will upgrade these packages regardless of the directive.
    * Default: `false`
* `unattended_verbose`: Define verbosity level of APT for periodic runs. The output will be sent to root.
    * Possible options:
      * `0`: no report
      * `1`: progress report
      * `2`: + command outputs
      * `3`: + trace on
    * Default: `0` (no report)
* `unattended_update_package_list`: Do "apt-get update" automatically every n-days (0=disable)
    * Default: `1`
* `unattended_download_upgradeable`: Do "apt-get upgrade --download-only" every n-days (0=disable)
    * Default: `0`
* `unattended_autoclean_interval`: Do "apt-get autoclean" every n-days (0=disable)
    * Default: `7`
* `unattended_clean_interval`: Do "apt-get clean" every n-days (0=disable)
    * Default: `0`
* `unattended_random_sleep`: Define maximum for a random interval in seconds after which the apt job starts (only for systems without systemd)
    * Default: `1800` (30 minutes)
* `unattended_dpkg_options`: Array of dpkg command-line options used during unattended-upgrades runs, e.g. `["--force-confdef"]`, `["--force-confold"]`
    * Default: `[]`
* `unattended_dl_limit`: Limit the download speed in kb/sec using apt bandwidth limit feature.
    * Default: disabled

## Origins Patterns

Origins Pattern is a more powerful alternative to the Allowed Origins option used in previous versions of unattended-upgrade.

Pattern is composed from specific keywords:

* `a`,`archive`,`suite` – e.g. `stable`, `trusty-security` (`archive=stable`)
* `c`,`component`   – e.g. `main`, `crontrib`, `non-free` (`component=main`)
* `l`,`label` – e.g. `Debian`, `Debian-Security`, `Ubuntu`
* `o`,`origin` – e.g. `Debian`, `Unofficial Multimedia Packages`, `Ubuntu`
* `n`,`codename` – e.g. `jessie`, `jessie-updates`, `trusty` (this is only supported with `unattended-upgrades` >= 0.80)
* `site` – e.g. `http.debian.net`

You can review the available repositories using `apt-cache policy` and debug your choice using `unattended-upgrades -d` command on a target system.

Additionally unattended-upgrades support two macros (variables), derived from `/etc/debian_version`:

* `${distro_id}` – Installed distribution name, e.g. `Debian` or `Ubuntu`.
* `${distro_codename}` – Installed codename, e.g. `jessie` or `trusty`.

Using `${distro_codename}` should be preferred over using `stable` or `oldstable` as a selected, as once `stable` moves to `oldstable`, no security updates will be installed at all, or worse, package from a newer distro release will be installed by accident. The same goes for upgrading your installation from `oldstable` to `stable`, if you forget to change this in your origin patterns, you may not receive the security updates for your newer distro release. With `${distro_codename}`, both cases can never happen.

## Role Usage Example

Example for Ubuntu, with custom [origins patterns](#patterns-examples), blacklisted packages and e-mail notification:

```yaml
- hosts: all
  roles:
  - role: jnv.unattended-upgrades
    unattended_origins_patterns:
    - 'origin=Ubuntu,archive=${distro_codename}-security'
    - 'o=Ubuntu,a=${distro_codename}-updates'
    unattended_package_blacklist: [cowsay, vim]
    unattended_mail: 'root@example.com'
```

_Note:_ You don't need to specify `unattended_origins_patterns`, the role will use distribution's default if the variable is not set.

### Patterns Examples

By default, only security updates are allowed for both Ubuntu and Debian. You can add more patterns to allow unattended-updates install more packages automatically, however be aware that automated major updates may potentially break your system.

#### For Debian

```yaml
unattended_origins_patterns:
  - 'origin=Debian,codename=${distro_codename},label=Debian-Security' # security updates
  - 'o=Debian,codename=${distro_codename},label=Debian' # updates including non-security updates
  - 'o=Debian,codename=${distro_codename},a=proposed-updates'
```

On debian wheezy, due to `unattended-upgrades` being `0.79.5`, you cannot use the `codename` directive.

You will have to do archive based matching instead:

```yaml
unattended_origins_patterns:
  - 'origin=Debian,a=stable,label=Debian-Security' # security updates
  - 'o=Debian,a=stable,l=Debian' # updates including non-security updates
  - 'o=Debian,a=proposed-updates'
```

Please be sure to read about the issues regarding this in the origin pattern documentation above.

#### For Ubuntu

In Ubuntu, archive always contains the distribution codename

```yaml
unattended_origins_patterns:
  - 'origin=Ubuntu,archive=${distro_codename}-security'
  - 'o=Ubuntu,a=${distro_codename}'
  - 'o=Ubuntu,a=${distro_codename}-updates'
  - 'o=Ubuntu,a=${distro_codename}-proposed-updates'
```


#### For Raspbian

In Raspbian, it is only possible to update all packages from the default repository, including non-security updates, or updating none.

Updating all, including non-security:

```yaml
unattended_origins_patterns:
  - 'origin=Raspbian,codename=${distro_codename},label=Raspbian'
```

You can not use the `codename` directive on raspbian wheezy, the same as with debian wheezy above.

To not install any updates on a raspbian host, just set `unattended_origins_patterns` to an empty list:
```
unattended_origins_patterns: []
```


## License

GPLv2
