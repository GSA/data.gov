
def run(playbook, stack, environment, tags = null, 
    skippedTags = null,  resource = null, hostname = null)
{
    dir('./ansible') {
        resource = (resource != null) ? resource : playbook
        def inventoryName = newInventory(playbook, stack, environment, resource, hostname)
        def extras = "-i ${inventoryName} --extra-vars \"${playbook}_hostname=${playbook}\""
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
def newInventory(playbook, stack, environment, resource = null, hostname = null,
    fileName = null)
{
    if (fileName == null) {
        fileName = "./${playbook}.hosts"
    }
    sh "rm -f ${fileName}"
    sh "echo '' > ${fileName}"
    resource = (resource != null) ? resource : playbook
    hostname = (hostname != null) ? hostname : playbook
    echo "hostname=${hostname}"
    def ip = discoverResourcePublicIp(stack, environment, resource)
    assert ip != "" :
        "No IP address found for ${env.AWS_REGION}:${stack}:${environment}:${resource}"
    echo "${stack}::${playbook} found at '${ip}'"
    writeFile encoding: 'ascii', file: fileName, 
        text: "${hostname} ansible_host=${ip}\n"
    sh "cat ${fileName}"
    return fileName
}

def discoverResourcePublicIp(stack, environment, resource) {
    return sh (
        script: """aws ec2 describe-instances \
            --region ${env.AWS_REGION} \
            --filter "Name=tag:System,Values=datagov" \
                     \"Name=tag:Stack,Values=${stack}\" \
                     \"Name=tag:Environment,Values=${environment}\" \
                     \"Name=tag:Resource,Values=${resource}\" \
                     \"Name=instance-state-name,Values=running\" \
            --query \"Reservations[].Instances[].{Ip:PublicIpAddress}\" \
            --output text
            """,
        returnStdout: true
    )
}

