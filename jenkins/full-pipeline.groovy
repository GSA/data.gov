#!groovy


def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/terraform.groovy"
    def playbook = load "./jenkins/playbook.groovy"

    terraform.run('infrastructure', environment)
    
    terraform.run('pilot', environment, "infrastructure")
    
    playbook.run("jumpbox", "pilot", environment, 
        "always,jumpbox,apache", "shibboleth", "bastion")
    
    playbook.run("datagov-web", "pilot", environment, null,
        "trendmicro,vim,deploy,deploy-rollback,secops,postfix",
        "wordpress-web", "wordpress-web")
}

def test(environment) {
    // Nothing here yet
}