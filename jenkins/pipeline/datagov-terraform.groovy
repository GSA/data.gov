
// NOTE ideally These pipeline scripts are convert to a 
// class structure, such that commonality can be inherrited


def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/provisioner/terraform.groovy"
    terraform.run('infrastructure', environment)   
    terraform.run('pilot', environment, "infrastructure")   
}

def test(environment) {
    // Nothing here yet
}


return this