env.AWS_REGION = "us-east-2"

stage('Initialize') {
    node("master") {
        checkout scm
        sh "touch ~/ansible-secret.txt"
    }
}

stage('Provision Infrastructure Stack') {
    node("master") {
        runTerraform('infrastructure', env.BRANCH_NAME)
    }
}

stage('Provision Pilot Stack') {
    node("master") {
        runTerraform('pilot', env.BRANCH_NAME, "infrastructure")
    }
}

stage('Provision jumpbox') {
    node('master') {
        runPlaybook("jumpbox", "pilot", "always,jumpbox,apache", 
            "shibboleth", "bastion")
    }
}

stage('Provision datagov-web') {
    node('master') {
        runPlaybook("datagov-web", "pilot", null,
            "trendmicro,vim,deploy,deploy-rollback,secops,postfix",
            "wordpress-web", "wordpress-web")
    }
}





def runTerraform(stack_name, branchName, dependsOnStack = null) {
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


def runPlaybook(playbook, stack, tags = null, skippedTags = null, 
    resource = null, hostname = null)
{
    dir('./ansible') {
        resource = (resource != null) ? resource : playbook
        def inventoryName = newInventory(playbook, stack, resource, hostname)
        def extras = "-vvv -i ${inventoryName} --extra-vars \"${playbook}_hostname=${playbook}\""
        if (tags != null) {
            ansiblePlaybook playbook: "./${playbook}.yml",
                sudoUser: "ubuntu",
                credentialsId: "${env.AWS_REGION}-datagov_dev_${resource}",
                tags: "${tags}",
                skippedTags: "${skippedTags}",
                forks: 5,
                extras: extras
        } else {
            ansiblePlaybook playbook: "./${playbook}.yml",
                sudoUser: "ubuntu",
                credentialsId: "${env.AWS_REGION}-datagov_dev_${resource}",
                skippedTags: "${skippedTags}",
                forks: 5,
                extras: extras
        }
    }
}



// The following function are no longer necessary when 
// changing to Ansible dynamic inventory
def newInventory(playbook, stack, resource = null, hostname = null,
    branchName = null, fileName = null)
{
    if (fileName == null) {
        fileName = "./${playbook}.hosts"
    }
    sh "rm -f ${fileName}"
    sh "echo '' > ${fileName}"
    branchName = (branchName) ? branchName : env.BRANCH_NAME
    resource = (resource != null) ? resource : playbook
    hostname = (hostname != null) ? hostname : playbook
    echo "hostname=${hostname}"
    def ip = discoverResourcePublicIp(stack, branchName, resource)
    assert ip != "" : "No IP address found for ${env.AWS_REGION}:${stack}:${branchName}:${resource}"
    echo "${stack}::${playbook} found at '${ip}'"
    writeFile encoding: 'ascii', file: fileName, 
        text: "${hostname} ansible_host=${ip}\n"
    sh "cat ${fileName}"
    return fileName
}

def discoverResourcePublicIp(stack, branchName, resource) {
    return sh (
        script: """aws ec2 describe-instances \
            --region ${env.AWS_REGION} \
            --filter "Name=tag:System,Values=datagov" \
                     \"Name=tag:Stack,Values=${stack}\" \
                     \"Name=tag:Branch,Values=${branchName}\" \
                     \"Name=tag:Resource,Values=${resource}\" \
                     \"Name=instance-state-name,Values=running\" \
            --query \"Reservations[].Instances[].{Ip:PublicIpAddress}\" \
            --output text
            """,
        returnStdout: true
    )
}

