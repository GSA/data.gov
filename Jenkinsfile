pipeline {
  agent any
  stages {
    stage('workflow:sandbox') {
      when { anyOf { environment name: 'DATAGOV_WORKFLOW', value: 'sandbox' } }
      stages {
        stage('build') {
          steps {
            ansiColor('xterm') {
              sh 'docker build --build-arg APP_UID=$(id -u) --build-arg APP_GID=$(id -g) -t datagov/datagov-deploy:${branch_name} .'
            }
          }
        }
        stage('deploy:sandbox') {
          when { anyOf { branch 'develop' } }
          environment {
            ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
            SSH_KEY_FILE = credentials('datagov-sandbox')
            DATAGOV_ANSIBLE_INVENTORY = 'sandbox'
          }
          steps {
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY -m ping all'
            }
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible-playbook --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY site.yml'
            }
          }
        }
      }
    }
    stage('workflow:production') {
      when { anyOf { environment name: 'DATAGOV_WORKFLOW', value: 'production' } }
      stages {
        stage('build') {
          steps {
            ansiColor('xterm') {
              sh 'docker build --build-arg APP_UID=$(id -u) --build-arg APP_GID=$(id -g) -t datagov/datagov-deploy:${branch_name} .'
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
            DATAGOV_ANSIBLE_INVENTORY = 'staging'
          }
          steps {
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY -m ping all'
            }
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible-playbook --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY site.yml'
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
            DATAGOV_ANSIBLE_INVENTORY = 'mgmt'
          }
          steps {
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY -m ping all'
            }
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible-playbook --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY site.yml'
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
            DATAGOV_ANSIBLE_INVENTORY = 'production'
          }
          steps {
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY -m ping all'
            }
            ansiColor('xterm') {
              sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:${branch_name} pipenv run ansible-playbook --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/$DATAGOV_ANSIBLE_INVENTORY site.yml'
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
