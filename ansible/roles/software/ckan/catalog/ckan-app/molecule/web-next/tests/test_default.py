import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


virtualenv_path = '/usr/lib/ckan'


def test_gunicorn_conf(host):
    f = host.file('/etc/supervisor/conf.d/supervisord_gunicorn.conf')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o644
    assert f.contains('[program:catalog-web]')


def test_web_mem_cpu_conf(host):
    f = host.file('/etc/supervisor/conf.d/supervisord_web_mem_cpu.conf')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o644
    assert f.contains('[program:check-mem-cpu]')


def test_cpu_mem_check_sh(host):
    f = host.file('/usr/bin/cpu-mem-check.sh')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o755
