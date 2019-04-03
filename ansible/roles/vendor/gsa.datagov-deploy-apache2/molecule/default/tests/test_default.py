import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

python_prefix = '/usr'


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


def test_http(host):
    http = host.socket('tcp://0.0.0.0:80')

    assert http.is_listening


def test_https(host):
    # tcp://443 fails on bionic
    # https://github.com/philpep/testinfra/issues/355
    https = host.socket('tcp://0.0.0.0:443')

    assert https.is_listening


def test_www(host):
    uri = host.ansible('uri', 'url="http://localhost/"', check=False)

    assert uri['status'] == 200


def test_no_indexes(host):
    # Test we don't get an Indexes/MultiView from http://localhost:443
    # TODO we should set up the role to assume redirect http -> https which
    # would remove the need for this.
    uri = host.ansible('uri', 'url="http://localhost:443/?M=A"', check=False)

    # This results in 403 Forbidden on trusty but 404 on
    # bionic. As long as its not 200, we're ok.
    assert uri['status'] in [403, 404]


def test_ssl_versions(host):
    mod_ssl = host.file('/etc/apache2/mods-enabled/ssl.conf')

    assert mod_ssl.exists
    assert mod_ssl.contains('SSLProtocol TLSv1.1 TLSv1.2')
