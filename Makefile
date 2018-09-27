.PHONY: lint setup test

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

test:
	bundle exec kitchen test --concurrency 2
