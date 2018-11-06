# Base images the others are based on, usually the platform
PLATFORM_IMAGES := ubuntu1404-ansible

# Images built from the ansible playbooks
TARGET_IMAGES := catalog-base


# Wildcard patterns for platform targets, e.g. %-ubuntu1404-ansible
PLATFORM_TARGETS := $(patsubst %,\%:%, $(PLATFORM_IMAGES))
# target-platform combinations
TAG_TARGETS := $(foreach target, $(TARGET_IMAGES), $(patsubst %, $(target)-%, $(PLATFORM_IMAGES)))

all: $(TAG_TARGETS)

$(PLATFORM_IMAGES):
	docker build --tag $@ $@

catalog-base-%: %
	./docker-playbook.sh catalog-base $* catalog.yml --tags=frontend --skip-tags=solr,db,trendmicro,fluentd,skip_in_kitchen


.PHONY: all $(PLATFORM_IMAGES)
