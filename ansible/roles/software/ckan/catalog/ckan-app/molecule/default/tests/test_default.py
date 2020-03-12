import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


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
