import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

python_prefix = '/usr/local'


def test_wsgi_python_home(host):
    wsgi_config = \
        host.file('/etc/apache2/conf-enabled/wsgi-custom-python.conf')

    assert wsgi_config.exists
    assert wsgi_config.user == 'root'
    assert wsgi_config.group == 'root'
    assert wsgi_config.mode == 0o644
    assert wsgi_config.contains("WSGIPythonHome %s" % python_prefix)


def test_apache2(host):
    service = host.service('apache2')

    assert service.is_enabled
    assert service.is_running


def test_ports(host):
    http = host.socket('tcp://80')

    assert http.is_listening


def test_ssl_versions(host):
    mod_ssl = host.file('/etc/apache2/mods-enabled/ssl.conf')

    assert mod_ssl.exists
    assert mod_ssl.contains('SSLProtocol TLSv1.1 TLSv1.2')
