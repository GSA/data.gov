import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


virtualenv_path = '/usr/lib/ckan'


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


def test_production_ini(host):
    production_ini = host.file('/etc/ckan/production.ini')

    assert production_ini.exists
    assert production_ini.user == 'root'
    assert production_ini.group == 'www-data'
    assert production_ini.mode == 0o640


def test_supervisor_conf(host):
    conf = host.file('/etc/supervisor/conf.d/catalog-harvest.conf')

    assert conf.exists
    assert conf.user == 'root'
    assert conf.group == 'root'
    assert conf.mode == 0o644

    assert conf.contains('harvester run')
    assert conf.contains('harvester fetch_consumer')
    assert conf.contains('harvester gather_consumer')


def test_cron(host):
    cron = host.file('/etc/cron.d/ckan')

    assert cron.exists
    assert cron.user == 'root'
    assert cron.group == 'root'
    assert cron.mode == 0o644

    assert cron.contains('supervisorctl start harvest-run')


def test_harvest_report_cron(host):
    cron = host.file('/etc/cron.d/harvest-report')

    assert cron.exists
    assert cron.user == 'root'
    assert cron.group == 'root'
    assert cron.mode == 0o644
    assert cron.contains('harvest-report.sh')


def test_harvest_report_script(host):
    script = host.file('/usr/local/bin/harvest-report.sh')

    assert script.exists
    assert script.user == 'root'
    assert script.group == 'root'
    assert script.mode == 0o755
    assert script.contains('^#!/bin/bash')


def test_who_ini(host):
    who_ini = host.file('/etc/ckan/who.ini')

    assert who_ini.exists
    assert who_ini.user == 'root'
    assert who_ini.group == 'www-data'
    assert who_ini.mode == 0o640
