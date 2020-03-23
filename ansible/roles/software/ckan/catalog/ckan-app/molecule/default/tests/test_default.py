import os
from datetime import datetime

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_var_lib_ckan(host):
    var_lib_ckan = host.file('/var/lib/ckan')

    assert var_lib_ckan.exists
    assert var_lib_ckan.is_directory
    assert var_lib_ckan.user == 'www-data'
    assert var_lib_ckan.group == 'www-data'
    assert var_lib_ckan.mode == 0o755


def test_var_tmp_ckan(host):
    var_tmp_ckan = host.file('/var/tmp/ckan')

    assert var_tmp_ckan.exists
    assert var_tmp_ckan.is_directory
    assert var_tmp_ckan.user == 'www-data'
    assert var_tmp_ckan.group == 'www-data'
    assert var_tmp_ckan.mode == 0o755


def test_dynamic_menu(host):
    """Test menu.json is prepopulated with old modification time
    https://github.com/GSA/catalog-app/issues/76"""
    dynamic_menu = host.file('/var/tmp/ckan/dynamic_menu/menu.json')

    assert dynamic_menu.exists
    assert dynamic_menu.user == 'www-data'
    assert dynamic_menu.group == 'www-data'
    assert dynamic_menu.mode == 0o644
    # We do a loose assertion on mtime to avoid timezone issues
    assert dynamic_menu.mtime < datetime(2020, 1, 2)


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
