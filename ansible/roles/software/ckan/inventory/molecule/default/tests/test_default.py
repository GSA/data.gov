import os

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
