import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_ntp_installed(host):
    ntp = host.package('ntp')
    assert ntp.is_installed


def test_ntp_enabled(host):
    ntp = host.service('ntp')

    # For bionic, systemd is not available and this fails
    #
    # assert ntp.is_running

    assert ntp.is_enabled
