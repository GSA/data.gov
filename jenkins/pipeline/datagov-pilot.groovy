
def run(environment) {
    initialize(environment)
    provision(environment)
    test(environment)
}

def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/provisioner/terraform.groovy"
    terraform.run('pilot', environment, "infrastructure")   

    def playbook = load "./jenkins/provisioner/playbook.groovy"
    def system = "datagov"
    playbook.run("jumpbox", system, environment, "bastion", 
        "always,jumpbox,apache", "shibboleth")
    playbook.run("datagov-web", system, environment, "wordpress-web",
    	null, "trendmicro,vim,deploy,deploy-rollback,secops,postfix")
}

def test(environment) {
    // Nothing here yet
}


return this