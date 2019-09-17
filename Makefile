KITCHEN_SUITES := \
  crm-web \
  dashboard-web

MOLECULE_SUITES := \
  software/ckan/catalog/harvest \
  software/ckan/catalog/www \
  software/ckan/catalog/ckan-app \
  software/ckan/inventory \
  software/ckan/native-login \
  software/common/php-fixes

PLAYBOOKS := \
  ansible/actions/reboot.yml \
  ansible/catalog-web.yml \
  ansible/catalog-worker.yml \
  ansible/catalog.yml \
  ansible/ci.yml \
  ansible/ckan-native-login.yml \
  ansible/common.yml \
  ansible/crm-web.yml \
  ansible/dashboard-web.yml \
  ansible/datagov-web.yml \
  ansible/efk-nginx.yml \
  ansible/efk-stack.yml \
  ansible/elastalert.yml \
  ansible/elasticsearch.yml \
  ansible/inventory.yml \
  ansible/jumpbox.yml \
  ansible/kibana.yml \
  ansible/newrelic-java.yml \
  ansible/newrelic-php.yml \
  ansible/pycsw.yml \
  ansible/site.yml \
  ansible/solr.yml

# Create test-kitchen-<suite> targets
KITCHEN_SUITE_TARGETS := $(patsubst %,test-kitchen-%,$(KITCHEN_SUITES))

# Create test-molecule-<suite> targets
MOLECULE_SUITE_TARGETS := $(patsubst %,test-molecule-%,$(MOLECULE_SUITES))

# Used for parallelization on CircleCI. See `circleci tests glob`.
# https://circleci.com/docs/2.0/parallelism-faster-jobs/
circleci-glob:
	@echo $(MOLECULE_SUITE_TARGETS) | sed -e 's/ /\n/g'

update-vendor:
	cd ansible && \
	ansible-galaxy install -r requirements.yml

update-vendor-verbose:
	cd ansible && \
	ansible-galaxy install -r requirements.yml -vvv

update-vendor-force:
	cd ansible && \
	ansible-galaxy install -r requirements.yml --force

update-vendor-force-verbose:
	cd ansible && \
	ansible-galaxy install -r requirements.yml --force -vvv

setup:
	pipenv install --dev
	bundle install

lint:
	ansible-playbook -i ansible/inventories/production --syntax-check $(PLAYBOOKS)
	ansible-lint -v -x ANSIBLE0010 --exclude ~/.ansible $(PLAYBOOKS)

$(KITCHEN_SUITE_TARGETS):
	cd ansible && \
	bundle exec kitchen test $(subst test-kitchen-,,$@)

$(MOLECULE_SUITE_TARGETS):
	cd ansible/roles/$(subst test-molecule-,,$@) && \
	molecule test --all

test: $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)
test-kitchen-only: $(KITCHEN_SUITE_TARGETS)
test-molecule-only: $(MOLECULE_SUITE_TARGETS)

.PHONY: lint setup test $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)
