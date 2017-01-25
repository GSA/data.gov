
// NOTE ideally These pipeline scripts are convert to a 
// class structure, such that commonality can be inherrited

def initialize(environment) {
}

def provision(environment) {
    runPipeline('shared-infrastructure', environment)
    runPipeline('datagov-pilot', environment)
    runPipeline('d2d', environment)
}

def test(environment, outputDirectory) {
	return false
}

def runPipeline(name, environment) {
    def pipeline = load "./jenkins/pipeline/${name}.groovy"
    def separator ="===================="
    echo "${separator} ${name} :: ${environment} ${separator}"
    pipeline.run(environment)
    echo "${separator} ${name} :: ${environment} [Done] ${separator}"
}


return this