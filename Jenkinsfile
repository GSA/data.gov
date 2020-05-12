pipeline {
  agent any
  stages {
    stage('build') {
      steps {
        ansiColor('xterm') {
          sh 'docker build --build-arg APP_UID=$(id -u) --build-arg APP_GID=$(id -g) -t datagov/datagov-deploy .'
        }
      }
    }
    stage('ping:sandbox') {
      when { anyOf { branch 'develop' } }
      environment {
        ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
        SSH_KEY_FILE = credentials('datagov-sandbox')
      }
      steps {
        ansiColor('xterm') {
          sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:latest pipenv run ansible --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/sandbox -m ping all'
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
          sh 'docker run --rm -v $SSH_KEY_FILE:$SSH_KEY_FILE -v $ANSIBLE_VAULT_FILE:$ANSIBLE_VAULT_FILE -u $(id -u) datagov/datagov-deploy:latest pipenv run ansible-playbook --key-file=$SSH_KEY_FILE --vault-password-file=$ANSIBLE_VAULT_FILE --inventory inventories/sandbox site.yml --skip-tags database'
        }
      }
    }
  }
  post {
    failure {
      step([$class: 'GitHubIssueNotifier'])
    }
  }
}
