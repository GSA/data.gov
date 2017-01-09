
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
    def bastionResourceName = 'bastion'
    def fileName = newInventoryFile()
    appendInventoryEntry(fileName, bastionResourceName, "pilot")
    ansiblePlaybook playbook: './ansible/jumpbox.yml',
        sudoUser: "ubuntu",
        credentialsId: "datagov_dev_${bastionResourceName}",
        tags: "always,jumpbox,apache",
        skippedTags: "shibboleth",
        extras: "-vvv -i ${fileName} --extra-vars \"bastion_hostnames=${bastionResourceName}\""
}


def manageStack(stack_name, branchName, dependsOnStack = null) {
    dir("terraform/") {
        def script = "${pwd()}/bin/manage-stack.sh"
        def args = []
        sh "chmod 700 '${script}'"
        args << "-v"
        args << "-v"
        args << "--action create"
        if (dependsOnStack) {
            args << "--input stack-output:///${dependsOnStack}/${branchName}"
        }
        sh "'${script}' ${args.join(' ')} '${stack_name}' '${branchName}'"
    }
}

def newInventoryFile(fileName = "./hosts") {
    sh "rm -f ${fileName}"
    sh "echo '' > ${fileName}"
    return fileName
}


def appendInventoryEntry(fileName, resourceName, stackName, branchName = null) {
    def resourceIP = discoverResourcePublicIp(stackName,
        (branchName) ? branchName : env.BRANCH_NAME,
        resourceName)
    writeFile encoding: 'ascii', file: fileName, 
         text: "${resourceName} ansible_host=${resourceIP}\n"
}

def discoverResourcePublicIp(stackName, branchName, resourceName) {
    return sh (
        script: """aws ec2 describe-instances \
            --region us-east-1 \
            --filter "Name=tag:System,Values=datagov" \
                     \"Name=tag:Stack,Values=${stackName}\" \
                     \"Name=tag:Branch,Values=${branchName}\" \
                     \"Name=tag:Resource,Values=${resourceName}\" \
                     \"Name=instance-state-name,Values=running\" \
            --query \"Reservations[].Instances[].{Ip:PublicIpAddress}\" \
            --output text
            """,
        returnStdout: true
    )
}
