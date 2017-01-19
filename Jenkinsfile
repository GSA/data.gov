#!groovy

env.AWS_REGION = "us-east-2"
def pipeline = null

stage('Initialize') {
    node("master") {
        checkout scm
        sh "touch ~/ansible-secret.txt"
    }
    pipeline = load("./jenkins/full-pipeline.groovy")
}

pipeline.run()


