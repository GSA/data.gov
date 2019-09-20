import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_wsgi(host):
    f = host.file('/etc/ckan/apache.wsgi')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'www-data'
    assert f.mode == 0o644


def test_apache2_site(host):
    f = host.file('/etc/apache2/sites-enabled/ckan.conf')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'www-data'
    assert f.mode == 0o644
    assert f.contains('ErrorLog /var/log/ckan/ckan.error.log')
