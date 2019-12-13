import os
import sys
import hashlib

activate_this = os.path.join('/usr/lib/datapusher/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

import ckanserviceprovider.web as web
{% if inventory_app_environment == 'staging' %}
# Use GSA's CA for python requests in staging
os.environ.setdefault('REQUESTS_CA_BUNDLE', '/etc/ssl/certs/ca-certificates.crt')
{% endif %}
os.environ['JOB_CONFIG'] = '/etc/ckan/datapusher_settings.py'
web.init()

import datapusher.jobs as jobs

application = web.app
