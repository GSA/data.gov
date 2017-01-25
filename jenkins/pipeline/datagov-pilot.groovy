
def run(environment) {
    initialize(environment)
    provision(environment)
    test(environment)
}

def initialize(environment) {
}

def provision(environment) {
    // def terraform = load "./jenkins/provisioner/terraform.groovy"
    // terraform.run('pilot', environment, "infrastructure")   

    // def playbook = load "./jenkins/provisioner/playbook.groovy"
    // def system = "datagov"
    // playbook.run("jumpbox", system, environment, "bastion", 
    //     "always,jumpbox,apache", "shibboleth")
    // playbook.run("datagov-web", system, environment, "wordpress-web",
    // 	null, "trendmicro,vim,deploy,deploy-rollback,secops,postfix")
}

def test(environment, outputDirectory) {
    // TODO Should get IPs from stack or ansible ec2.py,
    //      rather than have to discovering them
    echo "Define environment file in ${pwd()}"
    def environmentFile = "${pwd()}/${environment}-input.json"
    echo "Create environment file ${environmentFile} "
    def ips = discoverPublicIps(environment, 'wordpress-web')
    ips = ips.split("\n")

    echo "hosts to test ${ips}]"
    for (ip in ips) {
        dir ("./postman/pilot") {
            def host = "${ip}"
            sh "ls -al"
            sh "cat ./environment-template.json"
            def command = "cat ./environment-template.json | "
            command = "${command} sed -e 's|__WORDPRESS_WEB_HOST__|${host}|g' > "
            command = "${command} ${environmentFile}"
            echo "About to run [${command}]"
            sh command
            sh "cat ${environmentFile}"
            echo "Run test"
            runTest("verify-pilot", environmentFile, outputDirectory)
        }
    }
}

def runTest(testName, environmentFile, outputDirectory) {
    def arguments = [
        "./${testName}.json",
        "-e ${environmentFile}",
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