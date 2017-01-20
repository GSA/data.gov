
// NOTE ideally These pipeline scripts are convert to a 
// class structure, such that commonality can be inherrited

def initialize(environment) {
}

def provision(environment) {
    runPipeline('datagov-terraform', environment)
    runPipeline('datagov-ansible', environment)
    runPipeline('d2d', environment)
}

def test(environment) {
}

def runPipeline(name, environment) {
    def pipeline = load "./${name}.groovy"
    def separator ="===================="
    echo "${separator} ${name} :: ${environment} ${separator}"
    pipeline.run(environment)
}


return this