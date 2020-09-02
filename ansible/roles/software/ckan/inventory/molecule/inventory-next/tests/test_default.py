import re


def test_gunicorn_datapusher(host):
    supervisor_output = host.check_output('supervisorctl status')
    assert re.search(r'gunicorn-datapusher +RUNNING', supervisor_output)
