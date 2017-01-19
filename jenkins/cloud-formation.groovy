
def run(stack_name, environment, inputs = null, waitForCompletion = 30) {
    dir("cloud-formation/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        def args = []
        sh "chmod 700 '${script}'"
        args << "-v"
        args << "-v"
        args << "--action create"
        args << "--region us-east-2"
        args << "--bucket datagov-provisioning"
        args << "--bucket-region us-east-1"
        args << "--source-dir ${pwd}/cloud-formation/${stack_name}"
        args << "--input ${pwd}/cloud-formation//${stack_name}/input.tfvars"
        if (waitForCompletion != null) {
            args << "--wait-for-completion ${waitForCompletion}"
        }
        for (input in inputs) {
             args << "--input ${input}}"
        }
        sh "'${script}' ${args.join(' ')} '${stack_name}' '${environment}'"
    }
}

return this


