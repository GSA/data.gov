import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

PHP_VERSION = "7.0"


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_php_cli_worker_conf(host):
    # CLI usage has a long execution time
    max_execution_time = 600
    conf = host.file('/etc/php/%s/cli/conf.d/90-worker.ini' % PHP_VERSION)

    assert conf.exists
    assert conf.contains('max_execution_time = %s' % max_execution_time)


def test_php_fpm_session_conf(host):
    conf = host.file('/etc/php/%s/fpm/conf.d/90-session.ini' % PHP_VERSION)

    assert conf.exists
    assert conf.contains('session.cookie_httponly = On')
    assert conf.contains('session.cookie_secure = On')


def test_php_fpm_conf(host):
    # Web requests must have a fast execution time
    max_execution_time = 30
    conf = host.file('/etc/php/%s/fpm/php.ini' % PHP_VERSION)

    assert conf.exists
    assert conf.contains('max_execution_time = %s' % max_execution_time)
