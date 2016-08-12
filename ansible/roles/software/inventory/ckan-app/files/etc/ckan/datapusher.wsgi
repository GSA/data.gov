import os
import sys
import hashlib

activate_this = os.path.join('/usr/lib/datapusher/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

import ckanserviceprovider.web as web
os.environ['JOB_CONFIG'] = '/etc/ckan/datapusher_settings.py'
web.init()

import datapusher.jobs as jobs

application = web.app


