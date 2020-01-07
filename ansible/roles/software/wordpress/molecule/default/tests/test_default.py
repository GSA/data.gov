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


def test_app_saml_config_dir(host):
    saml_config_dir = host.file(
        '%s/web/app/uploads/saml-20-single-sign-on/etc' % wordpress_app_dir
    )

    assert saml_config_dir.exists
    assert saml_config_dir.user == wordpress_user
    assert saml_config_dir.group == 'www-data'
    assert saml_config_dir.mode == 0o775


def test_app_w3tc_config_dir(host):
    w3tc_config_dir = host.file('%s/web/app/w3tc-config' % wordpress_app_dir)

    assert w3tc_config_dir.exists
    assert w3tc_config_dir.user == wordpress_user
    assert w3tc_config_dir.group == 'www-data'
    assert w3tc_config_dir.mode == 0o775


def test_app_cache_dir(host):
    cache_dir = host.file('%s/web/app/cache' % wordpress_app_dir)

    assert cache_dir.exists
    assert cache_dir.user == wordpress_user
    assert cache_dir.group == 'www-data'
    assert cache_dir.mode == 0o775


def test_app_uploads_dir(host):
    uploads_dir = host.file('%s/web/app/uploads' % wordpress_app_dir)

    assert uploads_dir.exists
    assert uploads_dir.user == wordpress_user
    assert uploads_dir.group == 'www-data'
    assert uploads_dir.mode == 0o775


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
    assert certificate.group == 'www-data'
    assert certificate.mode == 0o644


def test_saml2_key(host):
    key = host.file(
        '%s/web/app/uploads/saml-20-single-sign-on'
        '/etc/certs/1/1.key' % wordpress_app_dir
    )

    assert key.exists
    assert key.user == wordpress_user
    assert key.group == 'www-data'
    assert key.mode == 0o640


def test_saml2_ini(host):
    ini = host.file(
        '%s/web/app/uploads/saml-20-single-sign-on'
        '/etc/config/saml20-idp-remote.ini' % wordpress_app_dir
    )

    assert ini.exists
    assert ini.user == wordpress_user
    assert ini.group == 'www-data'
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
