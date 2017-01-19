#!groovy

env.AWS_REGION = "us-east-2"

stage('Initialize') {
    node("master") {
        checkout scm
        sh "touch ~/ansible-secret.txt"
    }
}

(load "./jenkins/full-pipeline.groovy").run()


