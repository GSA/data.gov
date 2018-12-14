# CHANGELOG
## MASTER

### v2.0.1
* Fix issue `src file does not exist` cause by testrb

### v2.0.0
* Bump ansible version to 2.2
* Update readme

### v1.3.9
* Fix bugs
* Use a non-root user by default for the installation.

### v1.3.8
* Bump ruby version to 2.2.2
* Fix Bundler symlinking on system path
* This fixes the location of the bundler pointing to the global ruby version
* Ensure a default value is supplied when detecting ruby, fixes #78
* Update rvm installer path
* Update become method
* Ensure installed rubies and gems are owned correctly by rvm1_user

### v1.3.7
* Fix #40 by using a proper gem path

### v1.3.6
* Recent changes to rvm made bundler not get installed by default
* This patch installs bundler by default

### v1.3.5
* Ensure rvm1_user owns all rvm related files
* Allow passing in custom configuration options when installing ruby
	
### v1.3.4
* Change the default system wide install dir back to /usr/local/rvm
* Add the rvm1_user: 'root' default variable to let you set the rvm directory owner
* Update the README on why setting sudo: True is necessary

### v1.3.3
* Fix an incorrect condition which caused Ansible to error out

### v1.3.2
* Import the GPG signature every time rvm runs get [version].

### v1.3.1
* Add gpg signature verification

### v1.3.0
* Remove the python-httplib2 dependency so it should work on CentOS 7
* Change how versions are set, check the readme
* Always run rvm update unless you disable it by overwriting rvm1_rvm_check_for_updates

### v1.2.0
* Add CentOS/RHEL support 

### v1.1.1
* Fix #7 and #8 by no longer chowning the user:group
* Symlink the ruby related bins to /usr/local/bin when doing a system wide install
* Remove the temp install dir, always use /tmp
* Expose the rvm install flags in a new default variable rvm1_install_flags
* Change the default system wide install dir to /usr/local/lib/rvm
* Update the readme to be much more clear and provide 3 examples of how to install rvm
* Update the travis test to test against ansible 1.7.1 instead of 1.6.2
* Reformat all of the tasks to make them more readable and maintainable

### v1.0.2
* Force sudo as root when having to apt install python-httplib2, fixes #5.

### v1.0.1
* Install httplib2 if necessary (the ansible uri module depends on this)


### v1.0.0
* Add ability to define 1 or more ruby versions
* Add ability to delete ruby versions
* Expose a few useful variables and paths
* Switch over from nickjj.ruby to rvm1-ansible

### v0.1.9
* Really fix the detect tasks so they are idempotent

### v0.1.8
* Fix the detect tasks so they are idempotent

### v0.1.7
* Simplify the default ruby selection tasks into a single task

### v0.1.6
* Fix the default ruby selection task so it works for both local and system installs

### v0.1.5
* Fix a bug where /etc/profile.d/rvm.sh would be sourced even if it did not exist
* Add the --default flag to the rvm use command

### v0.1.4
* Bump the default version of ruby to 2.1.2

### v0.1.3
* Fix a bug with how the upgrade task was checking for rvm's existence
* Change how the role checks to determine if rvm is installed

### v0.1.2
* Allow you to specify a local path or url for the rvm installer script
* Allow you to specify a url or variable value for the latest rvm stable version number

### v0.1.1
* Auto upgrade rvm in an idempotent way but also allow you to turn this off
* Keep the rvm installer file on the server instead of deleting it in case http://get.rvm.io is down
* Toggle a variable to force update the installer

### v0.1.0
* View the readme to get a better understanding of what ansible-ruby does.
