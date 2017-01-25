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
env.PIPELINE_SCRIPT = getPipelineScript("full")

stage('Initialize') {
    node("master") {
        checkout scm
        withCredentials([[$class: 'UsernamePasswordMultiBinding', 
        	credentialsId: 'ansible-secret-dev', 
        	usernameVariable: 'UN', 
        	passwordVariable: 'PASSWORD']]) 
        {
            sh """
            	rm -rf ~/ansible-secret.txt && echo '${env.PASSWORD}' >> \
            	~/ansible-secret.txt
            """
        }
        //sh "touch ~/ansible-secret.txt"
    }
}

runPipeline(env.PIPELINE_SCRIPT)



def runPipeline(pipeline) {
    runStages(pipeline, "dev")
    runStages(pipeline, "prod")
}


def runStages(pipeline, environment) {
	def isDev = isDev(environment)
    if (isDev || isMaster()) {
        //initialize(environment)
        if (!isDev) {
        	proceed(pipeline, environment)
        }
        provision(pipeline, environment)
        test(pipeline, environment)
        // do other stages here
    } else {
    	echo "Skipping ${environment}, because feature branch (${env.BRANCH_NAME})"
    }
}

def proceed(pipeline, environment) {
	def label = getLabel(environment)
    stage("${pipeline}-${label}: Proceed?") {
    	node('master') {
			timeout(time:5, unit:'DAYS') {
              	input "Do you want to continue to ${label}?"
            }
         }
    }
}

def provision(pipeline, environment) {
    stage("${pipeline}-${getLabel(environment)}: Provision") {
        node('master') {
            getPipeline(pipeline).provision(nameEnvironment(environment))
        }
    }
}

def test(pipeline, environment) {
    stage("${pipeline}-${getLabel(environment)}: Test") {
        node('master') {
            def reportsDirectory = "test-reports" 
            def hasTests = getPipeline(pipeline).test(nameEnvironment(environment),
                "${pwd()}/${reportsDirectory}")
            if (hasTests) {
	            step([$class: 'JUnitResultArchiver',
    	            testResults: "**/${reportsDirectory}/TEST-*.xml"])
	        }
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

def getPipelineScript(defaultScript) {
	def selectors = getPipelineSelectors()
	def name = getPipelineName().toLowerCase()
	def script = defaultScript
	echo "Select pipeline (default: ${env.PIPELINE_SCRIPT})"
	for (s in selectors) {
		// Using ~ causes Jenkins to fail, citing that
		// the bitwise negate operator is not allowed
		// Therefore using the Pattern object explicitly
		echo "Checking ${name} against ${s.selector}"
		if (name ==~ s.selector) {
			echo "Selecting pipeline ${s.pipeline}"
			script = s.pipeline
			// NOTE that script could be change to return a list
			// of all matching pattern and then run all those pipelines
			// per environment
			break
		}
	}
	echo "Selected Pipeline=${script}"
	return script
}

def getPipelineName() {
	def names = env.JOB_NAME.split("/")
	def name = names[0]
	echo "JOB_NAME=${env.JOB_NAME}"
	echo" Pipeline Name=${name}"
	return name
}

def getPipelineSelectors() {
	def selectors = []
	selectors << [selector:/.*d2d.*/,             pipeline: "d2d" ]
	selectors << [selector:/.*shared.*infra.*/,  pipeline: "shared-infrastructure" ]
	selectors << [selector:/.*datagov.*pilot.*/,  pipeline: "datagov-pilot" ]
	return selectors
}

def getPipeline(name) {
   def pipeline = load "${pwd()}/jenkins/pipeline/${name}.groovy"
   return pipeline
}

def isMaster() {
    return (env.BRANCH_NAME.startsWith("master"))
}

def isDev(environment) {
    return  (environment == "dev")
}
