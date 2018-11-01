import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_user(host):
    user = host.user("ci")
    assert user.exists
    assert user.name == "ci"
    assert user.group == "ci"
    assert user.groups == ["ci"]
    assert user.shell == "/bin/bash"
    assert user.home == "/home/ci"


def test_datagov_deploy_repo(host):
    repo = host.file("/home/ci/datagov-deploy")
    assert repo.is_directory
    assert host.check_output(
        "cd /home/ci/datagov-deploy && git symbolic-ref --short HEAD"
    ) == "bsp-ci"


def test_cron_job(host):
    assert host.check_output(
        "crontab -l -u ci"
    ) == "0 12 * * * /home/ci/datagov-deploy/ci.sh"
