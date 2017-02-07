stage 'Initialize'
node("master") {
    checkout scm
}

stage 'Create/Update Infrastructure Stack'
node("master") {
    manageStack('infrastructure', env.BRANCH_NAME)
}

stage 'Create/Update Pilot Stack'
node("master") {
    manageStack('pilot', env.BRANCH_NAME, "infrastructure")
}


def manageStack(stack_name, branch_name, dependsOn = null) {
    dir("terraform/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        def args = []
        sh "chmod 700 '${script}'"
        args << "-v"
        args << "-v"
        args << "--action create"
        if (dependsOn) {
            args << "--input stack-output:///infrastructure/${env.BRANCH_NAME}"
        }
        sh "'${script}' ${args.join(' ')} '${stack_name}' '${branch_name}'"
    }
}
