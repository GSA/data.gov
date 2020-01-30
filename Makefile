MOLECULE_SUITES := \
  software/ckan/catalog/harvest \
  software/ckan/catalog/www \
  software/ckan/catalog/ckan-app \
  software/ckan/inventory \
  software/ckan/native-login \
  software/common/php-fixes

ANSIBLE_PLAYBOOKS := \
  actions/reboot.yml \
  actions/uninstall-fluentd.yml \
  catalog-web.yml \
  catalog-worker.yml \
  catalog.yml \
  ci.yml \
  ckan-native-login.yml \
  common.yml \
  crm-web.yml \
  dashboard-web.yml \
  datagov-web.yml \
  efk-nginx.yml \
  efk-stack.yml \
  elastalert.yml \
  elasticsearch.yml \
  inventory.yml \
  jenkins.yml \
  jumpbox.yml \
  kibana.yml \
  newrelic-java.yml \
  newrelic-php.yml \
  pycsw.yml \
  site.yml \
  solr.yml

# Create test-molecule-<suite> targets
MOLECULE_SUITE_TARGETS := $(patsubst %,test-molecule-%,$(MOLECULE_SUITES))

# Used for parallelization on CircleCI. See `circleci tests glob`.
# https://circleci.com/docs/2.0/parallelism-faster-jobs/
circleci-glob:
	@echo $(MOLECULE_SUITE_TARGETS) | sed -e 's/ /\n/g'

vendor:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/requirements.yml --force

setup:
	pipenv install --dev

lint:
	cd ansible && ansible-playbook --syntax-check $(ANSIBLE_PLAYBOOKS)
	cd ansible && ansible-lint -v -x ANSIBLE0010 --exclude=roles/vendor *.yml

$(MOLECULE_SUITE_TARGETS):
	cd ansible/roles/$(subst test-molecule-,,$@) && \
	molecule test --all

test: $(MOLECULE_SUITE_TARGETS)
test-molecule-only: $(MOLECULE_SUITE_TARGETS)

.PHONY: lint setup test $(MOLECULE_SUITE_TARGETS)
