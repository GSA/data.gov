# Minimal CKAN investigation environment

This directory is meant to contain scripts for the purposes of
inspecting various live configurations.  To run these scripts, an active
ckan environment is necessary.  This can be achieved by running `make up`
in either the `catalog.data.gov` or `inventory-app` repositories.


## Get all routes available in CKAN app

Add the file dynamically into the docker compose volume and then run,

Prerequisites:
- `mkdir temp` in root of repo
- add `- ./temp:/temp` to `ckan` service volumes in `docker-compose.yml`
- add `test_get_routes.py` to root of repo

docker-compose run ckan bash -c "pip install pytest mock pylons factory-boy pytest-ckan && pytest /app/test_get_routes.py"

Output file: `temp/routes.txt`
