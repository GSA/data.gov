import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')

url = "https://private.url.localdomain"
js1 = '/usr/lib/ckan/src/ckanext-datagovtheme/ckanext/datagovtheme/' \
      'fanstatic_library/scripts/tracking.js'
js2 = '/usr/lib/ckan/src/ckan/ckan/public/base/javascript/tracking.js'
js3 = '/usr/lib/ckan/src/ckan/ckan/public/base/javascript/tracking.min.js'


def test_tracking_url(host):
    f1 = host.file(js1)
    f2 = host.file(js2)
    f3 = host.file(js3)

    assert "$.ajax({url : '/_tracking'" not in f1.content_string
    assert "$.ajax({url : $('body').data('site-root') + '_tracking'" \
        not in f2.content_string
    assert "$.ajax({url:$('body').data('site-root')+'_tracking'" \
        not in f3.content_string

    string1 = "$.ajax({url : '" + url + "/_tracking'"
    assert string1 in f1.content_string

    string2 = "$.ajax({url : '" + url + "/_tracking'"
    assert string2 in f2.content_string

    string3 = "$.ajax({url:'" + url + "/_tracking'"
    assert string3 in f3.content_string
