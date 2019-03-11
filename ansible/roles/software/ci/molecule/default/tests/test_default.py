import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_user(host):
    user = host.user("ci")
    assert user.exists
    assert user.name == "ci"
    assert user.group == "ci"
    assert user.groups == ["ci"]
    assert user.home == "/home/ci"


def test_datagov_deploy_repo(host):
    repo = host.file("/home/ci/datagov-deploy/.git")
    assert repo.is_directory


def test_cron_job(host):
    assert "0 */6 * * * /home/ci/ci.sh inventories/example" in \
        host.check_output(
            "crontab -l -u ci"
        )
