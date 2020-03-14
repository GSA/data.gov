import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_var_tmp_ckan(host):
    var_tmp_ckan = host.file('/var/tmp/ckan')

    assert var_tmp_ckan.exists
    assert var_tmp_ckan.is_directory
    assert var_tmp_ckan.user == 'www-data'
    assert var_tmp_ckan.group == 'www-data'
    assert var_tmp_ckan.mode == 0o755


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
