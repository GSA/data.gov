KITCHEN_SUITES := \
  catalog-web \
  crm-web \
  dashboard-web \
  inventory-web \
  jekyll \
  logrotate

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
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --ignore-certs

update-vendor-verbose:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml -vvv --ignore-certs

update-vendor-force:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --force --ignore-certs

update-vendor-force-verbose:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --force -vvv --ignore-certs

setup:
	pip install -r requirements.txt
	bundle install

lint:
	ansible-playbook --syntax-check ansible/*.yml
	ansible-lint -v -x ANSIBLE0010 --exclude=ansible/roles/vendor ansible/*.yml

$(KITCHEN_SUITE_TARGETS):
	cd ansible && \
	bundle exec kitchen test $(subst test-kitchen-,,$@)

$(MOLECULE_SUITE_TARGETS):
	cd ansible/roles/$(subst test-molecule-,,$@) && \
	molecule test --all

test: $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)

.PHONY: lint setup test $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)
