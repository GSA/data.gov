import os
import re

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_apache2_sites(host):
    ckan = host.file('/etc/apache2/sites-enabled/ckan.conf')
    datapusher = host.file('/etc/apache2/sites-enabled/datapusher.conf')

    assert ckan.exists
    assert ckan.user == 'root'
    assert ckan.group == 'www-data'
    assert ckan.mode == 0o640
    assert ckan.contains('ErrorLog /var/log/inventory/ckan.error.log')

    assert datapusher.exists
    assert datapusher.user == 'root'
    assert datapusher.group == 'www-data'
    assert datapusher.mode == 0o640
    assert datapusher.contains(
        'ErrorLog /var/log/inventory/datapusher.error.log')


def test_apache2(host):
    apache2 = host.service('apache2')

    assert apache2.is_enabled
    assert apache2.is_running


def test_beaker_cache_cleanup(host):
    script = host.file('/usr/local/bin/beaker-cache-cleanup.sh')
    supervisor_conf = host.file(
        '/etc/supervisor/conf.d/beaker-cache-cleanup.conf')

    assert script.exists
    assert script.user == 'root'
    assert script.group == 'root'
    assert script.mode == 0o755
    assert script.contains('age_in_days')

    assert supervisor_conf.exists
    assert supervisor_conf.user == 'root'
    assert supervisor_conf.group == 'root'
    assert supervisor_conf.mode == 0o644
    assert supervisor_conf.contains(
        '/usr/local/bin/beaker-cache-cleanup.sh')


def test_gunicorn_web_app(host):
    supervisor_output = host.check_output('supervisorctl status')
    assert re.search(r'gunicorn-web-app +RUNNING', supervisor_output)


def test_gunicorn_datapusher(host):
    supervisor_output = host.check_output('supervisorctl status')
    assert re.search(r'gunicorn-datapusher +RUNNING', supervisor_output)
