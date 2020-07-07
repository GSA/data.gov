import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_tomcat(host):
    tomcat = host.service('tomcat')

    assert tomcat.is_running


def test_port(host):
    assert host.socket("tcp://0.0.0.0:8080").is_listening


def test_version(host):
    cmd = host.run("sh /opt/tomcat/bin/version.sh")

    assert cmd.succeeded
    assert "Apache Tomcat/9.0.36" in cmd.stdout


def test_cron(host):
    cron = host.file('/etc/cron.d/clean-tmp-files')

    assert cron.exists
    assert cron.user == 'root'
    assert cron.group == 'root'
    assert cron.mode == 0o644
    assert cron.contains('tmp*-*-*-*-*')


def test_saxon(host):
    saxon = host.file('/etc/saxon-license.lic')

    assert saxon.exists
    assert saxon.user == 'root'
    assert saxon.group == 'root'
    assert saxon.mode == 0o644
    assert 'Licensor=Saxonica' in saxon.content_string


def test_fgdc_app_file(host):
    app = host.file('/opt/tomcat/webapps/fgdc2iso/app.py')

    assert app.exists
    assert app.user == 'tomcat'
    assert app.group == 'tomcat'
    assert app.mode == 0o640
