// ============================================================================
// Assumes the script referenced in env.PIPELINE_SCRIPT
// has functions named
//   1. provision(environment) - that provisions the environment
//   2. test() - that tests the provisioined servers, not used yet
//   3. other, e.g. setUp/initialize (at start of pipeline) and 
//      tearDown/finalize (at end of pipeline) once implemented
// This script will invoke those scripts in the order given above

// Logic is to be added to select the correct pipeline script based 
// on phrases inthe name of the job name (env.JOB_NAME)
// ============================================================================

env.AWS_REGION = "us-east-2"
env.PIPELINE_SCRIPT = "full"

stage('Initialize') {
    node("master") {
    	setPipelineScript()
        checkout scm
        sh "touch ~/ansible-secret.txt"
    }
}


runPipeline()


def runPipeline() {
    runStages("dev")
    runStages("prod")
}


def runStages(environment) {
    if (isDev(environment) || isMaster()) {
        //initialize(environment)
        provision(environment)
        test(environment)
        // do other stages here
    } else {
    echo "Skipping ${environment}, because feature branch (${env.BRANCH_NAME})"
    }
}


def provision(environment) {
    stage("${getLabel(environment)}: Provision") {
        node('master') {
            getPipeline().provision(nameEnvironment(environment))
        }
    }
}

def test(environment) {
    stage("${getLabel(environment)}: Test") {
        node('master') {
            getPipeline().test(nameEnvironment(environment))
        }
    }
}

def nameEnvironment(environment) {
	if (isDev(environment) && !isMaster()) {
		environment = "${environment}-${env.BRANCH_NAME}"
	}
    return environment
}

def getLabel(environment) {
    return environment.toUpperCase()
}

def setPipelineScript() {
	def selector = getPipelineSelector()
	def name = getPipelineName()
	def script = env.PIPELINE_SCRIPT
	echo "Select pipeline (default: ${env.PIPELINE_SCRIPT})"
	for (e in selector) {
		// Using ~ causes Jenkins to fail, citing that
		// the bitwise negate operator is not allowed
		// Therefore using the Pattern object explicitly
		echo "Checking ${name} against ${e.value}"
		if (name ==~ e.value) {
			script = e.key
			// NOTE that this could be change to return a list
			// of all matching pattern and then run all those pipelines
			// per environment
			break
		}
	}
	// switch (name) {
	// 	case /d2d.*/:                 script = "d2d"; break;
	// 	case /datagov.*terraform.*/:  script = "datagov-terraform"; break;
	// 	case /datagov.*ansible.*/:    script = "datagov-ansible"; break;
	// }
	echo "Selected Pipeline=${env.PIPELINE_SCRIPT}"
	env.PIPELINE_SCRIPT = script
}

def getPipelineName() {
	def names = env.JOB_NAME.split("/")
	def name = names[0]
	echo "JOB_NAME=${env.JOB_NAME}"
	echo" Pipeline Name=${name}"
	return name
}

def getPipelineSelector() {
	def selector = [:]
	selector["d2d"] =  /$d2d.*/
	selector["datagov-terraform"] = /$datagov.*terraform.*/
	selector["datagov-ansible"] = /$datagov.*ansible.*/
	return selector
}

def getPipeline() {
   def pipeline = load "${pwd()}/jenkins/pipeline/${env.PIPELINE_SCRIPT}.groovy"
   return pipeline
}

def isMaster() {
    return (env.BRANCH_NAME.startsWith("master"))
}

def isDev(environment) {
    return  (environment == "dev")
}
