.PHONY: setup test

setup:
	bundle install
	pip install -r requirements.txt

lint:
	@ansible-lint --version
	ansible-lint -v .

test:
	bundle exec kitchen test --concurrency 2
