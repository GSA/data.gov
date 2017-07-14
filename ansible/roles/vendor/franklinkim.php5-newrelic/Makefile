PWD=$(shell pwd)
ROLE_NAME=franklinkim.php5-newrelic
ROLE_PATH=/etc/ansible/roles/$(ROLE_NAME)
TEST_VERSION=ansible --version
TEST_DEPS=ansible-galaxy install weareinteractive.apt franklinkim.php5 franklinkim.newrelic
TEST_SYNTAX=ansible-playbook -vv -i 'localhost,' -c local $(ROLE_PATH)/tests/main.yml --syntax-check
TEST_PLAYBOOK=ansible-playbook -vv -i 'localhost,' -c local $(ROLE_PATH)/tests/main.yml
TEST_CMD=$(TEST_DEPS); $(TEST_VERSION); $(TEST_SYNTAX); $(TEST_PLAYBOOK)

.PHONY: test
test:
	docker run -it --rm -e "ROLE_NAME=$(ROLE_NAME)" -v $(PWD):$(ROLE_PATH) williamyeh/ansible:ubuntu14.04 /bin/bash -c "$(TEST_CMD)"
