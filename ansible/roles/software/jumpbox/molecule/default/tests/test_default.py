import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


testuser = 'testuser'
removeduser = 'removeduser'
testuser_public_key = 'testuser-public-key-string'


def test_user_created(host):
    user = host.user(testuser)

    assert user.expiration_date is None
    assert user.home
    assert user.shell == '/bin/bash'
    assert user.password == '!', 'user password should be locked'


def test_authorized_keys(host):
    user = host.user(testuser)
    authorized_keys = host.file('%s/.ssh/authorized_keys' % user.home)

    assert authorized_keys.exists
    assert authorized_keys.contains(testuser_public_key)


def test_removed_user(host):
    passwd = host.file('/etc/passwd')

    assert not passwd.contains(removeduser)


def test_ssh_allowusers(host):
    ssh_config = host.file('/etc/ssh/sshd_config')

    assert ssh_config.contains(r'AllowUsers .*%s' % testuser), \
        '%s user should be allowed ssh access' % testuser
    assert not ssh_config.contains(r'AllowUsers .*%s' % removeduser), \
        '%s user should not be allowed ssh access' % removeduser

    assert ssh_config.contains(r'AllowGroups .*%s' % testuser), \
        '%s group should be allowed ssh access' % testuser
    assert not ssh_config.contains(r'AllowGroups .*%s' % removeduser), \
        '%s group should not be allowed ssh access' % removeduser
