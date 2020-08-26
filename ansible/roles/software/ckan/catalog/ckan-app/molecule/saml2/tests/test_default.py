import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_production_ini(host):
    """production.ini file is configured with saml2 plugin enabled."""
    production_ini = host.file('/etc/ckan/production.ini')

    assert production_ini.exists
    assert production_ini.user == 'root'
    assert production_ini.group == 'www-data'
    assert production_ini.mode == 0o640

    assert production_ini.contains('ckan.plugins =.*datajson_harvest')
    assert production_ini.contains('ckan.plugins =.*saml2')


def test_who_ini(host):
    """who.ini file is configured with saml2 authentication."""
    who_ini = host.file('/etc/ckan/who.ini')

    assert who_ini.exists
    assert who_ini.user == 'root'
    assert who_ini.group == 'www-data'
    assert who_ini.mode == 0o640

    assert who_ini.contains('saml2auth')


def test_saml2_dir(host):
    """saml2 configuration directory is installed."""
    saml2 = host.file('/etc/ckan/saml2')

    assert saml2.exists
    assert saml2.is_directory
    assert saml2.user == 'root'
    assert saml2.group == 'www-data'
    assert saml2.mode == 0o755


def test_saml2_attributes(host):
    attributes = host.file('/etc/ckan/saml2/attributemaps/basic.py')

    assert attributes.exists
    assert attributes.user == 'root'
    assert attributes.group == 'www-data'
    assert attributes.mode == 0o644


def test_saml2_uri(host):
    uri = host.file('/etc/ckan/saml2/attributemaps/saml_uri.py')

    assert uri.exists
    assert uri.user == 'root'
    assert uri.group == 'www-data'
    assert uri.mode == 0o644


def test_saml2_pki_dir(host):
    """saml2 pki configuration directory is installed."""
    saml2 = host.file('/etc/ckan/saml2/pki')

    assert saml2.exists
    assert saml2.is_directory
    assert saml2.user == 'root'
    assert saml2.group == 'www-data'
    assert saml2.mode == 0o750


def test_saml2_certificate(host):
    certificate = host.file('/etc/ckan/saml2/pki/mycert.pem')

    assert certificate.exists
    assert certificate.user == 'root'
    assert certificate.group == 'www-data'
    assert certificate.mode == 0o644


def test_saml2_key(host):
    key = host.file('/etc/ckan/saml2/pki/mykey.pem')

    assert key.exists
    assert key.user == 'root'
    assert key.group == 'www-data'
    assert key.mode == 0o640
