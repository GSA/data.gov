import re


def test_gunicorn_datapusher(host):
    supervisor_output = host.check_output('supervisorctl status')
    assert re.search(r'gunicorn-datapusher +RUNNING', supervisor_output)


def test_local_login(host):
    who = host.file('/etc/ckan/who.ini')

    assert who.exists
    assert who.user == 'root'
    assert who.group == 'www-data'
    assert who.mode == 0o640
    assert who.contains('friendlyform')
