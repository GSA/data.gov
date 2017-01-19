#!groovy

env.AWS_REGION = "us-east-2"
env.PIPELINE_SCRIPT = "jenkins/full-pipeline.groovy"

stage('Initialize') {
    node("master") {
        checkout scm
        sh "touch ~/ansible-secret.txt"
    }
}


// Assumes the script referenced in env.PIPELINE_SCRIPT
// has functions named
//   1. provision(environment) - that provisions the environment
//   2. test() - that tests the provisioined servers, not used yet
//   3. other, e.g. setUp/initialize (at start of pipeline) and 
//      tearDown/finalize (at end of pipeline) once implemented
// This script will invoke those scripts in the order given above

// Logic is to be added to select the correct pipeline script based 
// on phrases inthe name of the job name (env.JOB_NAME)

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
        // Do not process stages beyond dev for non-master 
        // (i.e. feature) branches
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


def isMaster() {
    return (env.BRANCH_NAME.startsWith("master"))
}

def isDev(environment) {
    return  (environment == "dev")
}

def nameEnvironment(environment) {
    return (isDev(environment) && !isMaster()) ? "-${env.BRANCH_NAME}" : ""
}

def getLabel(environment) {
    return environment.toUpperCase()
}

def getPipeline() {
   def pipeline = load "${pwd()}/${env.PIPELINE_SCRIPT}"
   return pipeline
}
