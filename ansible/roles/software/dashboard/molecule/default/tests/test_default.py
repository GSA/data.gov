import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

PHP_VERSION = "7.0"
app_user = 'dashboard'
deployment_version = 'test'


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


def test_app_home(host):
    home = host.file('/home/%s' % app_user)

    assert home.exists
    assert home.is_directory
    assert home.user == app_user
    assert home.group == app_user
    assert home.mode == 0o755


def test_app_current_link(host):
    expected_deployment = '/home/%s/deployments/%s' \
        % (app_user, deployment_version)
    current = host.file('/home/%s/current' % app_user)

    assert current.exists
    assert current.is_symlink
    assert current.user == app_user
    assert current.group == app_user
    assert current.linked_to == expected_deployment


def test_app_src_dir(host):
    src = host.file(
        '/home/%s/deployments/%s/src' % (app_user, deployment_version))

    assert src.exists
    assert src.is_directory
    assert src.user == app_user
    assert src.group == app_user
    assert src.mode == 0o755


def test_app_src_code(host):
    app_source = host.file(
        '/home/%s/deployments/%s/src/.git' % (app_user, deployment_version))

    assert app_source.exists
    assert app_source.is_directory
    assert app_source.user == app_user
    assert app_source.group == app_user
    assert app_source.mode == 0o755


def test_app_secrets_dir(host):
    secrets = host.file(
        '/home/%s/deployments/%s/secrets' % (app_user, deployment_version))

    assert secrets.exists
    assert secrets.is_directory
    assert secrets.user == app_user
    assert secrets.group == app_user
    assert secrets.mode == 0o750


def test_app_composer_vendor_dir(host):
    virtualenv = host.file(
        '/home/%s/deployments/%s/src/vendor' % (app_user, deployment_version))

    assert virtualenv.exists
    assert virtualenv.is_directory
    assert virtualenv.user == app_user
    assert virtualenv.group == app_user
    assert virtualenv.mode == 0o755
