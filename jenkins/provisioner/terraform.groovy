
def run(stack_name, environment, dependsOnStack = null) {
    dir("terraform/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        def args = []
        sh "chmod 700 '${script}'"
        args << "-v"
        args << "-v"
        args << "--action create"
        if (dependsOnStack) {
            args << "--input stack-output:///${dependsOnStack}/${environment}"
        }
        sh "'${script}' ${args.join(' ')} '${stack_name}' '${environment}'"
    }
}

return this