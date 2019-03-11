import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_filebeat_is_installed(host):
    package = host.package("filebeat")
    assert package.is_installed
    assert package.version.startswith("6")


def test_filebeat_service_enabled(host):
    service = host.service('filebeat')
    assert service.is_enabled


def test_filebeat_config_file_present(host):
    config_file = host.file('/etc/filebeat/filebeat.yml')
    assert config_file.is_file
