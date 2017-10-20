pipeline {
  agent none

  stages {


    stage('Build::Packer') {
      agent {
        docker {
          image 'hashicorp/packer'
        }
        
      }

      steps {
        parallel(
          "catalog-web": {
            sh 'packer build packer/catalog-web.json'
          },

          "catalog-harvester": {
            sh 'packer build packer/catalog-harvester.json'
          },

          "solr": {
            sh 'packer build packer/solr.json'
          }
        )
      }

    }


    stage('Deploy::Terragrunt') {
      agent any
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/GSA/datagov-infrastructure-live']]])

        sh 'cd dev/vpc && terragrunt apply'

        sh 'cd dev/db && terragrunt apply'

        sh 'cd dev/app && terragrunt apply'
      }
    }


  }
}
