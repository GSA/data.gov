import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_certificate(host):
    f = host.file('/etc/ssl/certs/datagov_host.crt')

    assert f.exists
    assert f.mode == 0o644
    assert f.user == 'root'
    assert f.group == 'root'


def test_key(host):
    f = host.file('/etc/ssl/private/datagov_host.key')

    assert f.exists
    assert f.mode == 0o640
    assert f.user == 'root'
    assert f.group == 'ssl-cert'
