pipeline {
  agent any
  stages {
    stage('workflow:sandbox') {
      when { anyOf { environment name: 'DATAGOV_WORKFLOW', value: 'sandbox' } }
      environment {
        BRANCH_NAME = "${branch_name}"
      }
      stages {
        stage('build') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy build'
            }
          }
        }
        stage('deploy:sandbox') {
          when { anyOf { branch 'develop' } }
          environment {
            ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
            SSH_KEY_FILE = credentials('datagov-sandbox')
          }
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping sandbox'
            }
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy deploy sandbox site.yml'
            }
          }
        }
      }
    }
    stage('workflow:production') {
      when { anyOf { environment name: 'DATAGOV_WORKFLOW', value: 'production' } }
      environment {
        BRANCH_NAME = "${branch_name}"
      }
      stages {
        stage('build') {
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy build'
            }
          }
        }
        stage('deploy:staging') {
          when {
            anyOf {
              branch 'release/*'
              branch 'master'
            }
          }
          environment {
            ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
            SSH_KEY_FILE = credentials('ssh-staging')
          }
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping staging'
            }
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy deploy staging site.yml'
            }
          }
        }
        stage('deploy:mgmt') {
          when {
            anyOf {
              branch 'master'
            }
          }
          environment {
            ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
            SSH_KEY_FILE = credentials('ssh-mgmt')
          }
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping mgmt'
            }
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy deploy mgmt site.yml'
            }
          }
        }
        stage('deploy:production') {
          when {
            anyOf {
              branch 'master'
            }
          }
          environment {
            ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
            SSH_KEY_FILE = credentials('ssh-production')
          }
          steps {
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy ping production'
            }
            ansiColor('xterm') {
              sh 'bin/jenkins-deploy deploy production site.yml'
            }
          }
        }
      }
    }
  }
  post {
    always {
      step([$class: 'GitHubIssueNotifier', issueAppend: true])
    }
  }
}
