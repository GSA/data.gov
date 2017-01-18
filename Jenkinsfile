env.AWS_REGION = "us-east-2"

stage('Initialize') {
    node("master") {
        checkout scm
        sh "touch ~/ansible-secret.txt"
    }
}

provision(devEnvironmentName())
if (isMaster()) {
    provision("prod")
}

def provision(environment) {
    def label = ((environment.startsWith("dev")) ? "dev" : environment).
        toUpperCase();

    if (label != "DEV") {
        stage("Proceed to ${label}") {
            timeout(time:5, unit:'DAYS') {
                input "Deploy to ${label}?"
            }
        }
    }

    stage("${label}: Provision Infrastructure") {
        node("master") {
            runTerraform('infrastructure', environment)
        }
    }

    stage("${label}: Provision Pilot") {
        node("master") {
            runTerraform('pilot', environment, "infrastructure")
        }
    }

    stage("${label}: Provision Jumpbox") {
        node('master') {
            runPlaybook("jumpbox", "pilot", environment, 
                "always,jumpbox,apache", "shibboleth", 
                "bastion")
        }
    }

    stage("${label}: Provision Datagov-web") {
        node('master') {
            runPlaybook("datagov-web", "pilot", environment, null,
                "trendmicro,vim,deploy,deploy-rollback,secops,postfix",
                "wordpress-web",
                "wordpress-web")
        }
    }
}
def isMaster() {
    return (env.BRANCH_NAME == 'master') || (env.BRANCH_NAME == 'master-demo');
}

def devEnvironmentName() {
    return (isMaster()) ? "dev" : "dev-${env.BRANCH_NAME}"
}

def runTerraform(stack_name, environment, dependsOnStack = null) {
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


def runPlaybook(playbook, stack, environment, tags = null, 
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

