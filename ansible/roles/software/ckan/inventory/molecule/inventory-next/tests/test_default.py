

def test_gunicorn_datapusher(host):
    apache = host.file('/etc/apache2/sites-enabled/datapusher.conf')

    assert apache.exists
    assert apache.user == 'root'
    assert apache.group == 'www-data'
    assert apache.mode == 0o640
    assert apache.contains('WSGIScriptAlias')


def test_local_login(host):
    who = host.file('/etc/ckan/who.ini')

    assert who.exists
    assert who.user == 'root'
    assert who.group == 'www-data'
    assert who.mode == 0o640
    assert who.contains('friendlyform')
