// NOTE ideally These pipeline scripts are convert to a 
// class structure, such that commonality can be inherrited


def run(environment) {
    initialize(environment)
    provision(environment)
    test(environment)
}

def initialize(environment) {
}

def provision(environment) {
    def cloudFormation = load "./jenkins/provisioner/cloud-formation.groovy"
    cloudFormation.run('d2dbastion', environment)
}

def test(environment) {
    // Nothing here yet
}


return this