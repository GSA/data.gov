
// NOTE ideally These pipeline scripts are convert to a 
// class structure, such that commonality can be inherrited

def initialize(environment) {
}

def provision(environment) {
    getDatagovTerraform().run(environment)
    getDatagovAnsible().run(environment)
    getD2D.run(environment)
}

def test(environment) {
}

def getDatagovTerraform() {
    return (load "./datagov-terraform.groovy")
}

def getDatagovAnsible() {
    return (load "./datagov-ansible.groovy")
}

def getD2D() {
    return (load "./d2d.groovy")
}


return this