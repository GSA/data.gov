
def run(stack_name, environment, inputs = null, waitForCompletion = 60) {
    dir("cloud-formation/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        def args = []
        sh "chmod 700 '${script}'"
        args << "-v"
        args << "-v -v -v"
        args << "'${stack_name}' '${environment}'"
        args << "--action create"
        args << "--region us-east-2"
        args << "--bucket datagov-provisioning"
        args << "--bucket-region us-east-1"
        args << "--source-dir ${pwd()}/${stack_name}"
        args << "--input ${pwd()}/${stack_name}/input.tfvars"
        if (waitForCompletion != null) {
            args << "--wait-for-completion ${waitForCompletion}"
        }
        for (input in inputs) {
             args << "--input ${input}}"
        }
        sh "'${script}' ${args.join(' ')}"
    }
}

return this


