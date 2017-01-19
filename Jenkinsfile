#!groovy

env.AWS_REGION = "us-east-2"
env.PIPELINE_SCRIPT = "./jenkins/full-pipeline.groovy"

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
//   3. other, once implemented

// Logic is to be added to select the correct pipeline script based 
// on phrases inthe name of the job name (env.JOB_NAME)

runPipeline()


def runPipeline() {
    runStages("dev")
    runStages("prod")
}


def runStages(environment, isMaster) {
    def isDev = (environment == "dev")
    if (isDev(environment) || isMaster) {
        provision(environment)
        test(environment)
        // do other stages here
    } else {
        // Do not process stages beyond dev, 
        // unless master branch
    }
    
}


def provision(environment) {
    stage("${labelEnvironment}: Provision") {
        node('master') {
            getPipeline().provision(nameEnvironment(environment))
        }
    }
}

def test(environment) {
    stage("${labelEnvironment}: Test") {
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

def labelEnvironment(environment) {
    return environment.toUpperCase()
}

def getPipeline() {
    return load(env.PIPELINE_SCRIPT)
}