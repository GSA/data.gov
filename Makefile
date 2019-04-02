KITCHEN_SUITES := \
  catalog-web \
  crm-web \
  dashboard-web \
  efk-nginx \
  efk-stack \
  inventory-web \
  jekyll \
  logrotate \
  unattended-upgrades

MOLECULE_SUITES := \
  software/ci \
  software/catalog/harvest \
  software/catalog/www \
  software/ckan/native-login \
  software/common/php-fixes \
  software/common/tls

# Create test-kitchen-<suite> targets
KITCHEN_SUITE_TARGETS := $(patsubst %,test-kitchen-%,$(KITCHEN_SUITES))

# Create test-molecule-<suite> targets
MOLECULE_SUITE_TARGETS := $(patsubst %,test-molecule-%,$(MOLECULE_SUITES))

# Used for parallelization on CircleCI. See `circleci tests glob`.
# https://circleci.com/docs/2.0/parallelism-faster-jobs/
circleci-glob:
	@echo $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS) | sed -e 's/ /\n/g'

update-vendor:
	pipenv run ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml

update-vendor-verbose:
	pipenv run ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml -vvv

update-vendor-force:
	pipenv run ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --force

update-vendor-force-verbose:
	pipenv run ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --force -vvv

setup:
	pipenv install --dev
	bundle install

lint:
	pipenv run ansible-playbook --syntax-check ansible/*.yml
	pipenv run ansible-lint -v -x ANSIBLE0010 --exclude=ansible/roles/vendor ansible/*.yml

$(KITCHEN_SUITE_TARGETS):
	cd ansible && \
	pipenv run bundle exec kitchen test $(subst test-kitchen-,,$@)

$(MOLECULE_SUITE_TARGETS):
	cd ansible/roles/$(subst test-molecule-,,$@) && \
	pipenv run molecule test --all

test: $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)

.PHONY: lint setup test $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)
