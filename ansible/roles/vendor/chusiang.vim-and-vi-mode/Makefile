.PHONY: main init syntax_check lint_check up run clean retag_latest

main: syntax_check lint_check

init:
	if [ ! -d "/tmp/ansible-retry" ]; then mkdir "/tmp/ansible-retry"; fi

syntax_check:
	ansible-playbook --syntax-check provision.yml

lint_check:
	ansible-lint provision.yml

up:
	vagrant up

run:
	ansible-playbook provision.yml -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory

clean:
	-rm -f *.retry ubuntu-*-console.log
	vagrant destroy -f

# Retag and push the latest tag.
retag_latest:
	-sh files/retag_latest.sh
