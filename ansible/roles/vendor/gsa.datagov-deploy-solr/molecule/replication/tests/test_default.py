import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('solr-replica')

solr_home = '/var/solr'
app_type = 'catalog'


def test_solrconfig(host):
    config = host.file('%s/data/%s/conf/solrconfig.xml'
                       % (solr_home, app_type))

    assert config.exists
    assert config.user == 'solr'
    assert config.group == 'solr'
    assert config.contains('<str name="masterUrl">http://solr-master:8983'
                           + '/solr/%s</str>' % app_type)
