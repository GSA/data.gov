# Issue #6512: alphabetical catalog search

Implementation for [GSA/data.gov#6512](https://github.com/GSA/data.gov/issues/6512).
The application code lives in separate repositories, so this directory contains
one applicable patch per repository. Working implementations are also available
locally in `/tmp/issue-6512/datagov-catalog` and
`/tmp/issue-6512/datagov-harvester`.

## Bases and changes

| Repository | Base commit | Patch |
| --- | --- | --- |
| GSA/datagov-catalog | `cb78526cbb1049092f96cb7133a231372ff710ff` | [datagov-catalog.patch](datagov-catalog.patch) |
| GSA/datagov-harvester | `f7a8a92d540ab3264966bf334b9326fc55cefad3` | [datagov-harvester.patch](datagov-harvester.patch) |

Both mappings gain a `title.normalized` keyword subfield using the existing
lowercase normalizer. Catalog accepts `sort=title` in route validation and API
schemas, and exposes **Title (A-Z)** in the shared search/organization dropdown.
Sorting uses the full normalized title ascending, missing titles last, and
document ID descending to break ties. Original titles and analyzed text search
are preserved. Query/filter preservation and cursor pagination use existing
application behavior.

The patches include mapping tests in both repositories, catalog query/schema/API
and rendered-page tests, two browser tests, an API changelog entry, and rollout
instructions. No database migration is needed.

## Apply

Run these commands in each application's checkout, replacing `/path/to/data.gov`
with the absolute path to this repository:

```bash
# In GSA/datagov-harvester:
git apply --check /path/to/data.gov/patches/6512/datagov-harvester.patch
git apply /path/to/data.gov/patches/6512/datagov-harvester.patch

# In GSA/datagov-catalog:
git apply --check /path/to/data.gov/patches/6512/datagov-catalog.patch
git apply /path/to/data.gov/patches/6512/datagov-catalog.patch
```

Both patches were checked and applied against clean archives of their base
commits; the resulting files were compared with the implementation checkouts.

## Published implementation commits

Both application changes have been committed and pushed to the contributor's
forks on branch `fix/6512-title-sort`:

- Catalog PR: https://github.com/GSA/datagov-catalog/pull/514
- Harvester PR: https://github.com/GSA/datagov-harvester/pull/1101
- [Catalog: `7b992acc321f09eaf16386dd3ed31e69a8fdf09c`](https://github.com/rafamolina1/datagov-catalog/commit/7b992acc321f09eaf16386dd3ed31e69a8fdf09c)
- [Harvester: `5cce80f8506e39fe7cc50ef27ba42dff4d0376d1`](https://github.com/rafamolina1/datagov-harvester/commit/5cce80f8506e39fe7cc50ef27ba42dff4d0376d1)

These are feature-branch commits; they have not been merged into GSA's
repositories. The patches above reproduce the same application changes.

## Validation

Executed with Python 3.14, an isolated PostgreSQL/PostGIS 16 database, and
OpenSearch 2.11.1. Python dependencies were installed in a temporary virtual
environment from catalog's declared requirements, rather than its Poetry lock.

| Check | Result |
| --- | --- |
| Catalog `pytest tests/unit/ -q` | 410 passed |
| Catalog browser tests matching `title_sort`, Chrome headless | 2 passed |
| Harvester `pytest --noconftest tests/unit/search/test_mappings.py -q` | 3 passed |
| Catalog Ruff check; Black and isort checks on application/tests | Passed |
| Harvester Ruff, Black, isort on changed Python files | Passed |
| Catalog `npm ci` and `npm run build` | Passed |
| `git diff --check` in both implementation checkouts | Passed |

The harvester mapping tests are independent of its Flask/DB fixtures; its full
test suite was not run. Catalog emitted 26 existing warnings for the local
OpenSearch test server's self-signed TLS certificate. Asset compilation emitted
Sass deprecation warnings.

Coverage includes case-insensitive ordering, full-title sorting including stop
words, equal normalized titles across page boundaries, absent/null titles,
query and repeated keyword filters, original title preservation, request/response
schemas, selected dropdown state, organization pages, pagination links, actual
sort changes in the browser, and HTMX loading of additional results.

## Release

Deploy harvester's mapping change first with the
`force re-index recommended` PR label. Complete and validate the replacement
OpenSearch cluster in each environment before deploying catalog's sort support
there. Updating the mapping alone does not populate existing documents.

After the reindex, verify the normalized field is populated and title ordering
works; after catalog deploy, smoke-test `/search?sort=title`, filters, and cursor
pagination. The harvester patch adds these checks to its existing reindex runbook.
Rolling back catalog does not require removing the additional index subfield.

The implementation has been submitted through the linked application PRs.
No production deployment or reindex has been performed.
