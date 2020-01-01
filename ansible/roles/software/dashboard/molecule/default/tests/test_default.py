import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


dashboard_user = 'ubuntu'


def test_log_dir(host):
    log_dir = host.file('/var/log/dashboard')

    assert log_dir.exists
    assert log_dir.is_directory
    assert log_dir.user == dashboard_user
    assert log_dir.group == dashboard_user


def test_supervisor_conf(host):
    supervisor = host.file('/etc/supervisor/conf.d/dashboard.conf')

    assert supervisor.exists
    assert supervisor.user == 'root'
    assert supervisor.group == 'root'
    assert supervisor.mode == 0o644
    assert supervisor.contains('program:dashboard-cfo-act-download')
    assert supervisor.contains('program:dashboard-cfo-act-full-scan')
    assert supervisor.contains('user=%s' % dashboard_user)


def test_cron(host):
    cron = host.file('/etc/cron.d/dashboard')

    assert cron.exists
    assert cron.user == 'root'
    assert cron.group == 'root'
    assert cron.mode == 0o644
    assert cron.contains('supervisorctl start dashboard-cfo-act-download')
    assert cron.contains('supervisorctl start dashboard-cfo-act-full-scan')
