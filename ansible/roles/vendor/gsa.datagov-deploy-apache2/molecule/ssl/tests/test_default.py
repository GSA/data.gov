import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_ssl_conf(host):
    f = host.file('/etc/apache2/mods-available/ssl.conf')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.contains(
        'SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem')
    assert f.contains(
        'SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key')
