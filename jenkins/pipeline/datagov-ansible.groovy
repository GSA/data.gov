
def initialize(environment) {
}

def provision(environment) {
    def playbook = load "./jenkins/provisioner/playbook.groovy"
    def system = "datagov"
    playbook.run("jumpbox",  system, environment, "bastion", 
        "always,jumpbox,apache", "shibboleth")
    playbook.run("datagov-web", system, environment, "wordpress-web",
    	null, "trendmicro,vim,deploy,deploy-rollback,secops,postfix")
}

def test(environment) {
    // Nothing here yet
}


return this