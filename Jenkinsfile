pipeline {
  agent any
  options {
    disableConcurrentBuilds()
    copyArtifactPermission('*')
  }
  stages {
    stage('workflow:sandbox') {
      when {
        allOf {
          environment name: 'DATAGOV_WORKFLOW', value: 'sandbox'
          anyOf {
            branch 'develop'
          }
        }
      }
      stages {
        stage('build') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy init'
              sh 'bin/jenkins-deploy build'
              sh 'tar czf datagov-deploy.tar.gz *'
            }
          }
        }
        stage('deploy:sandbox') {
          environment {
            ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
            SSH_KEY_FILE = credentials('datagov-sandbox')
          }
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping sandbox'
              sh 'bin/jenkins-deploy deploy sandbox site.yml'
            }
          }
        }
      }
    }
    stage('workflow:production') {
      when {
        allOf {
          environment name: 'DATAGOV_WORKFLOW', value: 'production'
          anyOf {
            branch 'master'
          }
        }
      }
      environment {
        ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
        SSH_KEY_FILE = credentials('datagov-prod-ssh')
      }
      stages {
        stage('build') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy init'
              sh 'bin/jenkins-deploy build'
              sh 'tar czf datagov-deploy.tar.gz *'
            }
          }
        }
        stage('deploy:staging') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping staging'
              sh 'bin/jenkins-deploy deploy staging site.yml'
            }
          }
        }
        stage('deploy:production') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping production \\!jumpbox'
              sh 'bin/jenkins-deploy deploy production site.yml --limit \\!jumpbox'
            }
          }
        }
        stage('deploy:mgmt') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping mgmt \\!jumpbox'
              sh 'bin/jenkins-deploy deploy mgmt site.yml --limit \\!jumpbox'
            }
          }
        }
      }
    }
  }
  post {
    success {
      archiveArtifacts artifacts: 'datagov-deploy.tar.gz', onlyIfSuccessful: true
    }
    always {
      step([$class: 'GitHubIssueNotifier', issueAppend: true, issueRepo: 'https://github.com/gsa/data.gov.git'])
    }
  }
}
