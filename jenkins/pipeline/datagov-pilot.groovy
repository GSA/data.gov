
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
    playbook.run("datagov-web-demo", system, environment, "wordpress-web")
}

def test(environment, outputDirectory) {
    // TODO Should get IPs from stack or ansible ec2.py,
    //      rather than have to discovering them
    def environmentFile = "${pwd()}/${environment}-input.json"
    def ips = discoverPublicIps(environment, 'wordpress-web')
    dir ("./postman/pilot") {
        for (ip in ips) {
            def command = "cat ./environment-template.json | " + 
                "sed -e 's|__WORDPRESS_WEB_HOST__|${ip}|g' > " +
                "${environmentFile}"
            sh command
            runTest("verify-pilot", environmentFile, outputDirectory)
        }
    }
    return true
}



def runTest(testName, environmentFile, outputDirectory) {
    def arguments = [
        "./${testName}.json",
        "--environment ${environmentFile}",
        " --reporters junit,cli",
        " --reporter-junit-export ${outputDirectory}/TEST-${testName}.xml"
    ]
    def command = "newman run ${arguments.join(' ')}"
    sh command
    // sh "ls -al \"${outputDirectory}\""
}

def discoverPublicIps(environment, resource) {
    def ips = []
    def results = sh (
            returnStdout: true, 
            script: """
                aws ec2 describe-instances \
                    --region ${env.AWS_REGION} \
                    --filter "Name=tag:System,Values=datagov" \
                             \"Name=tag:Stack,Values=pilot\" \
                             \"Name=tag:Environment,Values=${environment}\" \
                             \"Name=tag:Resource,Values=${resource}\" \
                             \"Name=instance-state-name,Values=running\" \
                    --query \"Reservations[].Instances[].{Ip:PublicIpAddress}\" \
                    --output text
            """).split('\n')
    for (String r: results) {
        r = r.trim()
        if (r) {
            ips << r
        }
    }
    return ips
}




return this