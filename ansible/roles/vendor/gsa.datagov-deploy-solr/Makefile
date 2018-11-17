SCENARIOS := \
  default \
  replication \
  solr4

SCENARIO_TARGETS := $(patsubst %,test-%, $(SCENARIOS))

setup:
	pip install -r requirements.txt

test: $(SCENARIO_TARGETS)

test-%:
	molecule test -s $*


.PHONY: setup test
