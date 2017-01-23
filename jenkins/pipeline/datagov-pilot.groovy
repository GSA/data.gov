
// NOTE ideally These pipeline scripts are convert to a 
// class structure, such that commonality can be inherrited


def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/provisioner/terraform.groovy"
    terraform.run('pilot', environment, "infrastructure")   

    def playbook = load "./jenkins/provisioner/playbook.groovy"
    playbook.run("jumpbox", "pilot", environment, 
        "always,jumpbox,apache", "shibboleth", "bastion")
    playbook.run("datagov-web", "pilot", environment, null,
        "trendmicro,vim,deploy,deploy-rollback,secops,postfix",
        "wordpress-web", "wordpress-web")
}

def test(environment) {
    // Nothing here yet
}


return this