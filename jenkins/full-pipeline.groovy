

def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/terraform.groovy"
    def playbook = load "./jenkins/playbook.groovy"
    def cloudFormation = load "./jenkins/cloud-formation.groovy"

    terraform.run('infrastructure', environment)
    
    terraform.run('pilot', environment, "infrastructure")
    
    playbook.run("jumpbox", "pilot", environment, 
        "always,jumpbox,apache", "shibboleth", "bastion")
    
    playbook.run("datagov-web", "pilot", environment, null,
        "trendmicro,vim,deploy,deploy-rollback,secops,postfix",
        "wordpress-web", "wordpress-web")

    cloudFormation.run('d2dbastion', environment)
}

def test(environment) {
    // Nothing here yet
}


return this