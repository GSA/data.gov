
def run(environment) {
    initialize(environment)
    provision(environment)
    test(environment)
}

def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/provisioner/terraform.groovy"
    terraform.run('infrastructure', environment)   
}

def test(environment, outputDirectory) {
    // Nothing here yet
    return false
}


return this