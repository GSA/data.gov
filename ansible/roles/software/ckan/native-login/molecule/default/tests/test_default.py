import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

virtualenv_path = '/usr/lib/ckan'


def test_compatible_repoze_who(host):
    packages = host.pip_package.get_packages(
        pip_path=('%s/bin/pip' % virtualenv_path)
    )

    assert 'repoze.who' in packages
    assert 'Paste' in packages

    assert '2.0' == packages['repoze.who'].get('version')
    assert '1.7.5.1' == packages['Paste'].get('version')


def test_saml2_disabled(host):
    production_ini = host.file('/etc/ckan/production.ini')

    assert not production_ini.contains(r'^ckan.plugins\b.*\bsaml2\b'), \
        'saml2 should not exist in ckan.plugins'


def test_who_ini_config(host):
    who_ini = host.file('/etc/ckan/who.ini')

    assert not who_ini.contains(r'saml2')


def test_apache(host):
    apache = host.service('apache2')

    assert apache.is_running
