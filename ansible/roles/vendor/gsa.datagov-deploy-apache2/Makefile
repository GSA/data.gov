.PHONY: setup test

setup:
	pip install -r requirements.txt

lint:
	@ansible-lint --version
	ansible-lint -v .

test:
	molecule test --all
