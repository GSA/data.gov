import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


wordpress_user = 'ubuntu'
wordpress_app_dir = '/var/www/datagov/new'
php_major_minor_version = '7.3'


def test_app_dir(host):
    app_dir = host.file(wordpress_app_dir)

    assert app_dir.is_directory
    assert app_dir.user == wordpress_user
    assert app_dir.group == wordpress_user
    assert app_dir.mode == 0o755


def test_app_git_dir(host):
    git_dir = host.file('%s/.git' % wordpress_app_dir)

    assert git_dir.is_directory
    assert git_dir.user == wordpress_user
    assert git_dir.group == wordpress_user
    assert git_dir.mode == 0o755


def test_app_vendor_dir(host):
    """Test the composer dependencies were installed."""
    vendor_dir = host.file('%s/vendor' % wordpress_app_dir)

    assert vendor_dir.is_directory
    assert vendor_dir.user == wordpress_user
    assert vendor_dir.group == wordpress_user
    assert vendor_dir.mode == 0o755


def test_app_env(host):
    env = host.file('%s/.env' % wordpress_app_dir)

    assert env.exists
    assert env.user == wordpress_user
    assert env.group == 'www-data'
    assert env.mode == 0o640

    assert env.contains(
        "DB_PASSWORD='superpassword'"
    )

    assert env.contains(
        "PRE_APPROVED_ADMINS=''"
    )


def test_log_dir(host):
    log_dir = host.file('/var/log/wordpress')

    assert log_dir.exists
    assert log_dir.is_directory
    assert log_dir.user == wordpress_user
    assert log_dir.group == wordpress_user


def test_saml2_certificate(host):
    certificate = host.file(
        '%s/web/app/uploads/saml-20-single-sign-on'
        '/etc/certs/1/1.cer' % wordpress_app_dir
    )

    assert certificate.exists
    assert certificate.user == wordpress_user
    assert certificate.group == wordpress_user
    assert certificate.mode == 0o644


def test_saml2_key(host):
    key = host.file(
        '%s/web/app/uploads/saml-20-single-sign-on'
        '/etc/certs/1/1.key' % wordpress_app_dir
    )

    assert key.exists
    assert key.user == wordpress_user
    assert key.group == wordpress_user
    assert key.mode == 0o644  # :sob:


def test_saml2_ini(host):
    ini = host.file(
        '%s/web/app/uploads/saml-20-single-sign-on'
        '/etc/config/saml20-idp-remote.ini' % wordpress_app_dir
    )

    assert ini.exists
    assert ini.user == wordpress_user
    assert ini.group == wordpress_user
    assert ini.mode == 0o644


def test_saml2_options(host):
    config = host.file('%s/saml.json' % wordpress_app_dir)

    assert config.exists
    assert config.user == wordpress_user
    assert config.group == wordpress_user
    assert config.mode == 0o644


def test_s3_config(host):
    s3 = host.file('%s/s3.json' % wordpress_app_dir)

    assert s3.exists
    assert s3.user == wordpress_user
    assert s3.group == wordpress_user
    assert s3.mode == 0o644


def test_w3_total_cache_hack(host):
    w3tc = host.file(
        '%s/web/app/plugins/w3tc-wp-loader.php' % wordpress_app_dir
    )

    assert w3tc.exists
    assert w3tc.user == wordpress_user
    assert w3tc.group == wordpress_user
    assert w3tc.mode == 0o644


def test_swfupload_removed(host):
    swfupload = host.file(
        '%s/web/wp/wp-includes/js/swfupload/swfupload.swf'
    )

    assert not swfupload.exists


def test_nginx(host):
    nginx = host.service('nginx')

    assert nginx.is_enabled
    assert nginx.is_running


def test_php_fpm(host):
    php_fpm = host.service('php%s-fpm' % php_major_minor_version)

    assert php_fpm.is_enabled
    assert php_fpm.is_running
