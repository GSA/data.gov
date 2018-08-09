## ANXS - apt [![Build Status](https://travis-ci.org/ANXS/apt.png)](https://travis-ci.org/ANXS/apt)

Ansible role which executes apt-get update to ensure the local APT package cache is up to date. At the same time, it cleans it from packages and .deb files which are no longer needed.


#### Variables

```yaml
apt_reset_source_list: no                     # reset the /etc/apt/sources.list to the default
apt_mirror_url: http://us.archive.ubuntu.com  # the mirror from where to install packages
apt_cache_valid_time: 3600                    # Time (in seconds) the apt cache stays valid
apt_install_recommends: no                    # whether or not to install the "recommended" packages
apt_install_suggests: no                      # whether or not to install the "suggested" packages
apt_autoremove: yes                           # remove packages that are no longer needed for dependencies
apt_autoremove_recommends: yes                # whether to automatically remove "recommended" packages
apt_autoremove_suggests: yes                  # whether to automatically remove "suggested" packages
apt_autoclean: yes                            # remove .deb files for packages no longer on your system
apt_default_packages:
  - python-apt
  - unattended-upgrades
```

Remark: Beware that setting `apt_install_recommends` and `apt_install_suggests` to `yes` may heavily increase the apt-requirements (and hence disk usage). You should proceed cautiously changing these. Similarly, `apt_autoremove_recommends` and `apt_autoremove_suggests` to `no` will make it harder to clean up.


#### Testing
This project comes with a VagrantFile, this is a fast and easy way to test changes to the role, fire it up with `vagrant up`

See [vagrant docs](https://docs.vagrantup.com/v2/) for getting setup with vagrant


#### License

Licensed under the MIT License. See the LICENSE file for details.


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/apt/issues)!
