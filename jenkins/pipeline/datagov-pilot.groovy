
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
    // TODO Should get IPs from stack or ansible ec2.py,
    //      rather than have to discovering them
    def ips = discoverPublicIps(environment, 'wordpress-web')
    def enviromentFile = "${pwd()}/${environment}-input.json"
    ips = ips.split("\n")

    echo "Loop ips [${ips}]"
    for (ip in ips) {
        echo "Create environment file"
        dir ("./postman/pilot") {
            def host = "${ip}"
            def command = """
                cat ./environment-template.json | \
                     sed -e 's|__WORDPRESS_WEB_HOST__|${host}|g' > \
                    ${enviromentFile}
            """
            echo "About to run [${command}]"
            sh command
            sh "cat ${enviromentFile}"
            echo "Run test"
            runTest("verify-pilot", enviromentFile, outputDirectory)
        }
    }
}

def runTest(testName, environmentFile, outputDirectory) {
    def arguments = [
        "./${testName}.json",
        "-e ${enviromentFile}",
        " --reports junit",
        " --reporter-junit-export ${outputDirectory}/TEST-${testName}.xml"
    ]
    sh "newman run ${arguments.join(' ')}"
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