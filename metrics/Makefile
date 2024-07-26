.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: py-lint
py-lint: ## Run python linting scanners and black
	poetry run ruff check . --fix

# Output documentation for top-level targets
# Thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
