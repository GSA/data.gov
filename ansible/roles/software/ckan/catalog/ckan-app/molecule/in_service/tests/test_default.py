import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_apache2_not_enabled(host):
    apache2 = host.service('apache2')

    assert not apache2.is_enabled
    assert not apache2.is_running
