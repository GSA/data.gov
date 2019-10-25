import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


virtualenv_path = '/usr/lib/ckan'

def test_production_ini(host):
    production_ini = host.file('/etc/ckan/production.ini')

    assert production_ini.exists
    assert production_ini.user == 'root'
    assert production_ini.group == 'www-data'
    assert production_ini.mode == 0o640

    assert production_ini.contains('ckan.plugins =.*datajson')
    assert not production_ini.contains('ckan.plugins =.*saml2')


def test_who_ini(host):
    who_ini = host.file('/etc/ckan/who.ini')

    assert who_ini.exists
    assert who_ini.user == 'root'
    assert who_ini.group == 'www-data'
    assert who_ini.mode == 0o640

    assert who_ini.contains(
        '^use = repoze.who.plugins.friendlyform:FriendlyFormPlugin'
    )

    assert not who_ini.contains('saml2auth')


def test_compatible_repoze_who(host):
    packages = host.pip_package.get_packages(
        pip_path=('%s/bin/pip' % virtualenv_path)
    )

    assert 'repoze.who' in packages
    assert 'Paste' in packages

    assert '2.0' == packages['repoze.who'].get('version')
    assert '1.7.5.1' == packages['Paste'].get('version')


def test_apache(host):
    apache = host.service('apache2')

    assert apache.is_running
    assert apache2.is_enabled
