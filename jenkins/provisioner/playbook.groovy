
def run(playbook, system, environment, resource, tags = null, 
    skippedTags = null)
{
    dir('./ansible') {
        def userName = "ubuntu"
        def credentialsID = getCredentialsId(system, environment, 
                (resource != null) ? resource : playbook)
        //def inventoryName = newInventory(playbook, system, environment, resource)
        //def extras = "-i ${inventoryName} -vvvv"
        def mapping = getDynamicMapping(system, environment, resource)
        def variable = "${playbook}_hosts"
        def extras = "--extra-vars \"${variable}=${mapping}\" -vvvv"

        if (tags != null) {
            ansiblePlaybook playbook: "./${playbook}.yml",
                sudoUser: userName,
                credentialsId: credentialsID,
                tags: "${tags}",
                skippedTags: "${skippedTags}",
                forks: 5,
                extras: extras
        } else {
            ansiblePlaybook playbook: "./${playbook}.yml",
                sudoUser: userName,
                credentialsId: credentialsID,
                skippedTags: "${skippedTags}",
                forks: 5,
                extras: extras
        }
    }
}

def getCredentialsId(system, environment, resource) {
    def isDev = (environment.startsWith("dev-"))
    def securityContext = ((isDev) ? "dev" : environment)
    return "${env.AWS_REGION}-${system}_${securityContext}_${resource}"
}

// def newInventory(playbook, system, environment, resource) {
//     def group_id = "${playbook}_hosts"
//     def variable = getDynamicMapping(system, environment, resource)
//     def inventoryText = [ "[${group_id}]${variable}" ]
//     def fileName = "./${playbook}.hosts"
//     sh "rm -f ${fileName}"
//     sh "echo '' > ${fileName}"
//     echo "group_id: ${group_id}; variable: ${variable}"
//     writeFile encoding: 'ascii', file: fileName, 
//         text: "${inventoryText.join('\n')}\n"
//     sh "cat ${fileName}"
//     return fileName
// }

def getDynamicMapping(system, environment, resource) {
    return "ec2_tag_Name_${system}_${environment}_${resource}"
}

return this
