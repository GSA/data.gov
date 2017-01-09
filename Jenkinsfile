stage 'Initialize'
node("master") {
    checkout scm
    sh "touch ~/ansible-secret.txt"
}

stage 'Create/Update Infrastructure Stack'
node("master") {
    manageStack('infrastructure', env.BRANCH_NAME)
}

stage 'Create/Update Pilot Stack'
node("master") {
    manageStack('pilot', env.BRANCH_NAME, "infrastructure")
}

stage 'Provision Bastion Server'
node('master') {
    def bastion_resource = 'bastion'
    def inventory = []
    inventory << [ resource: bastion_resource, stack: 'pilot' ]
    def file_name = createInventoryFile(inventory)
    ansiblePlaybook playbook: './ansible/jumpbox.yml', 
        sudoUser: "ubuntu",  credentialsId: "datagov_dev_${bastion_resource}",
        tags: "always,jumpbox,apache", skippedTags: 'shibboleth',
        extras: '-vvv -i ${file_name} --extra-vars "bastion_hostnames=${bastion_resource}"'
}




def manageStack(stack_name, branch_name, dependsOnStack = null) {
    dir("terraform/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        def args = []
        sh "chmod 700 '${script}'"
        args << "-v"
        args << "-v"
        args << "--action create"
        if (dependsOnStack) {
            args << "--input stack-output:///${dependsOnStack}/${branch_name}"
        }
        sh "'${script}' ${args.join(' ')} '${stack_name}' '${branch_name}'"
    }
}


def createInventoryFile(inventory, file_name = "./inventory") {
    def resource_ip = null
    sh "rm -f ${file_name}"
    sh "echo '' > ${file_name}"

    inventory.each {
        resource_ip = discoverResourcePublicIp(it.stack, 
            (it.branch) ? it.branch : ENV.BRANCH_NAME,
            it.resource)
        writeFile encoding: 'ascii', file: file_name, 
             text: "${it.resource} ansible_host=${resource_ip}\n"
    }
    return file_name
}

def discoverResourcePublicIp(stack_name, branch_name, resource_name) {
    return sh (
        script: """aws ec2 describe-instances \
            --region us-east-1 \
            --filter "Name=tag:System,Values=datagov" \
                     \"Name=tag:Stack,Values=${stack_name}\" \
                     \"Name=tag:Branch,Values=${branch_name}\" \
                     \"Name=tag:Resource,Values=${resource_name}\" \
                     \"Name=instance-state-name,Values=running\" \
            --query \"Reservations[].Instances[].{Ip:PublicIpAddress}\" \
            --output text
            """,
        returnStdout: true
    )
}
