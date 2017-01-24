
def run(environment) {
    initialize(environment)
    provision(environment)
    test(environment)
}

def initialize(environment) {
}

def provision(environment) {
    def terraform = load "./jenkins/provisioner/terraform.groovy"
    terraform.run('pilot', environment, "infrastructure")   

    def playbook = load "./jenkins/provisioner/playbook.groovy"
    def system = "datagov"
    playbook.run("jumpbox", system, environment, "bastion", 
        "always,jumpbox,apache", "shibboleth")
    playbook.run("datagov-web", system, environment, "wordpress-web",
    	null, "trendmicro,vim,deploy,deploy-rollback,secops,postfix")
}

def test(environment, outputDirectory) {
    def tests = ["verify-pilot"]
    // TODO Should get IPs from stack or ansible ec2.py,
    //      rather than have to discovering them
    def ips = discoverPublicIps(environment, 'wordpress-web').
        split("\n")
    def enviromentFile = "${pwd()}/${environment}-input.json"

    for (ip in ips) {
        sh "cat ./environment-template.json | " + 
            "sed -e \"s|__WORDPRESS_WEB_HOST__|${ip}|g\"" + 
            " > ${enviromentFile}"
        for (test in tests) {
            runTest(test, enviromentFile, outputDirectory)
        }
    }
}

def runTest(testName, environmentFile, outputDirectory) {
    def arguments = [
        "${testName}.json",
        "-e ${enviromentFile}",
        " --reports junit",
        " --reporter-junit-export ${outputDirectory}/TEST-${testName}.xml"
    ]

    dir ("./postman/pilot") {
        sh "cat ${enviromentFile}"
        sh "newman run ${arguments.join(" ")}"
    }
}

def discoverPublicIps(environment, resource) {
    return sh (
        script: """aws ec2 describe-instances \
            --region ${env.AWS_REGION} \
            --filter "Name=tag:System,Values=datagov" \
                     \"Name=tag:Stack,Values=pilot\" \
                     \"Name=tag:Environment,Values=${environment}\" \
                     \"Name=tag:Resource,Values=${resource}\" \
                     \"Name=instance-state-name,Values=running\" \
            --query \"Reservations[].Instances[].{Ip:PublicIpAddress}\" \
            --output text
            """,
        returnStdout: true
    )
}

return this