KITCHEN_SUITES := \
  catalog-web \
  catalog-harvester \
  crm \
  dashboard \
  efk-nginx \
  efk-stack \
  fluentd \
  inventory-web \
  jekyll \
  logrotate \
  misc \
  newrelic-infrastructure \
  postfix \
  secops \
  trendmicro \
  ubuntu \
  unattended-upgrades \
  web-proxy
  #crm-rollback \
  #dashboard-rollback \
  #datagov \
  #datagov-rollback \

KITCHEN_PLATFORMS := \
  ubuntu-1404

MOLECULE_SUITES := \
  software/ci \
  software/catalog/www \
  software/ckan/native-login \
  software/common/tls

# Create test-kitchen-<suite> targets
KITCHEN_SUITE_TARGETS := $(addprefix test-kitchen-, $(KITCHEN_SUITES))

# Create test-kitchen-<suite>.platform targets
KITCHEN_SUITE_PLATFORM_TARGETS := $(foreach platform, $(KITCHEN_PLATFORMS), $(addsuffix .$(platform), $(KITCHEN_SUITE_TARGETS)))

# Create test-molecule-<suite> targets
MOLECULE_SUITE_TARGETS := $(patsubst %,test-molecule-%,$(MOLECULE_SUITES))

# Used for parallelization on CircleCI. See `circleci tests glob`.
# https://circleci.com/docs/2.0/parallelism-faster-jobs/
circleci-glob:
	@echo $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS) | sed -e 's/ /\n/g'

kitchen_suite = $(word 1, $(subst ., , $(subst test-kitchen-,,$@)))
kitchen_platform = $(word 2, $(subst ., , $(subst test-kitchen-,,$@)))


update-vendor:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml

update-vendor-verbose:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml -vvv

update-vendor-force:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --force

update-vendor-force-verbose:
	ansible-galaxy install -p ansible/roles/vendor -r ansible/roles/vendor/requirements.yml --force -vvv

setup:
	pip install -r requirements.txt
	bundle install

lint:
	ansible-playbook --syntax-check ansible/*.yml
	ansible-lint -v -x ANSIBLE0010 --exclude=ansible/roles/vendor ansible/*.yml

# e.g. test-kitchen-<suite>: test-kitchen-<suite>.<platform>
$(KITCHEN_SUITE_TARGETS): %: $(addprefix %., $(KITCHEN_PLATFORMS))

$(KITCHEN_SUITE_PLATFORM_TARGETS):
	cd ansible && \
	bundle exec kitchen test $(kitchen_suite)-$(kitchen_platform)

$(MOLECULE_SUITE_TARGETS):
	cd ansible/roles/$(subst test-molecule-,,$@) && \
	molecule test --all

test: $(KITCHEN_SUITE_TARGETS) $(MOLECULE_SUITE_TARGETS)

.PHONY: lint setup test $(KITCHEN_SUITE_TARGETS) $(KITCHEN_SUITE_PLATFORM_TARGETS) $(MOLECULE_SUITE_TARGETS)
