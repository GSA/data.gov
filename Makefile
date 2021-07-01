MOLECULE_SUITES := \
  software/ckan/catalog/ckan-app \
  software/ckan/inventory \
  software/common/php-fixes

CATALOG_MOLECULE_SCENARIOS := \
  catalog-next \
  default \
  in_service \
  readwrite \
  saml2 \
  worker_main \
  worker-next

INVENTORY_MOLECULE_SCENARIOS := \
  default \
  in_service \
  inventory-next

COMMON_MOLECULE_SCENARIOS := \
  default

ANSIBLE_PLAYBOOKS := \
  actions/reboot.yml \
  actions/uninstall-fluentd.yml \
  actions/catalog-db-solr-sync.yml \
  catalog-web.yml \
  catalog-worker.yml \
  catalog.yml \
  common.yml \
  dashboard-web.yml \
  datagov-web.yml \
  fgdc2iso.yml \
  inventory.yml \
  jenkins.yml \
  jumpbox.yml \
  newrelic-java.yml \
  newrelic-php.yml \
  redis.yml \
  site.yml \
  smoke.yml \
  solr.yml

# Create test-molecule-<suite>-<scenario> targets
MOLECULE_TARGET_CATALOG := $(patsubst %,test-molecule-catalog-%,$(CATALOG_MOLECULE_SCENARIOS))

# Create test-molecule-<suite>-<scenario> targets
MOLECULE_TARGET_INVENTORY := $(patsubst %,test-molecule-inventory-%,$(INVENTORY_MOLECULE_SCENARIOS))

# Create test-molecule-<suite>-<scenario> targets
MOLECULE_TARGET_PHP := $(patsubst %,test-molecule-php-%,$(COMMON_MOLECULE_SCENARIOS))

# Create test-molecule-<suite> targets
MOLECULE_SUITE_TARGETS := $(MOLECULE_TARGET_CATALOG) $(MOLECULE_TARGET_INVENTORY) $(MOLECULE_TARGET_PHP)

# Used for parallelization on CircleCI. See `circleci tests glob`.
# https://circleci.com/docs/2.0/parallelism-faster-jobs/
circleci-glob:
	@echo $(MOLECULE_SUITE_TARGETS) | sed -e 's/ /\n/g'

vendor:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/requirements.yml --force

setup:
	pipenv install --dev

lint:
	cd ansible && ANSIBLE_INVENTORY_ANY_UNPARSED_IS_FAILED=true ansible-playbook --syntax-check --inventory inventories/production $(ANSIBLE_PLAYBOOKS)
	cd ansible && ANSIBLE_INVENTORY_ANY_UNPARSED_IS_FAILED=true ansible-playbook --syntax-check --inventory inventories/staging $(ANSIBLE_PLAYBOOKS)
	cd ansible && ANSIBLE_INVENTORY_ANY_UNPARSED_IS_FAILED=true ansible-playbook --syntax-check --inventory inventories/mgmt $(ANSIBLE_PLAYBOOKS)
	cd ansible && ANSIBLE_INVENTORY_ANY_UNPARSED_IS_FAILED=true ansible-playbook --syntax-check --inventory inventories/sandbox $(ANSIBLE_PLAYBOOKS)
	cd ansible && ansible-lint -v -x ANSIBLE0010 --exclude=roles/vendor $(ANSIBLE_PLAYBOOKS)

$(MOLECULE_TARGET_CATALOG):
	cd ansible/roles/software/ckan/catalog/ckan-app && \
	molecule test -s $(subst test-molecule-catalog-,,$@)

$(MOLECULE_TARGET_INVENTORY):
	cd ansible/roles/software/ckan/inventory && \
	molecule test -s $(subst test-molecule-inventory-,,$@)

$(MOLECULE_TARGET_PHP):
	cd ansible/roles/software/common/php-fixes && \
	molecule test -s $(subst test-molecule-php-,,$@)

test: $(MOLECULE_SUITE_TARGETS)
test-molecule-only: $(MOLECULE_SUITE_TARGETS)

.PHONY: lint setup test $(MOLECULE_SUITE_TARGETS)
