#!groovy

def run() {
    def isMaster = (env.BRANCH_NAME.startsWith("master"))
    provision("dev", isMaster)
    if (isMaster) {
        // Add other environments here
        provision("prod", isMaster)
    }
}

def provision(environmentID, isMaster) {
    def isDev = (environmentID == "dev")
    def environment = environmentID + 
        ((isDev && !isMaster) ? "-${env.BRANCH_NAME}" : "")
    def label = environmentID.toUpperCase()

    if (isDev || isMaster) {
        return
    }
    
    stage("${label}: Provision") {
        if (!isDev) {
            timeout(time:5, unit:'DAYS') {
                input "Proceed with deployment to ${label}?"
            }
        }

        node("master") {
            def terraform = load "./jenkins/terraform.groovy"
            def playbook = load "./jenkins/playbook.groovy"

            terraform.run('infrastructure', environment)
            
            terraform.run('pilot', environment, "infrastructure")
            
            playbook.run("jumpbox", "pilot", environment, 
                "always,jumpbox,apache", "shibboleth", "bastion")
            
            playbook.run("datagov-web", "pilot", environment, null,
                "trendmicro,vim,deploy,deploy-rollback,secops,postfix",
                "wordpress-web", "wordpress-web")
        }
    }
}

