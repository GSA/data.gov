stage 'Create pilot stack'
node("master") {
    checkout scm
    dir("terraform/") {
        def script = "${pwd()}/bin/create-stack.sh"
        sh "chmod 700 '${script}'"
        sh "'${script}' --destroy -v -v pilot '${env.BRANCH_NAME}'"
    }
}