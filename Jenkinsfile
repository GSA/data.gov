stage 'Create pilot stack'
node("master") {
    checkout scm
    dir("terraform/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        sh "chmod 700 '${script}'"
        sh "'${script}' -v -v --action create pilot '${env.BRANCH_NAME}'"
    }
}