#!/usr/bin/env bash

CFN_BOOTSTRAP='https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz'

AWS_STACKNAME=''
AWS_REGION='us-east-1'
RESOURCE=''
WAIT_HANDLE=''
CONFIG_SETS=''


function get_parameters {
    while test $# -gt 0; do
        case $1 in
          --stack)           shift; AWS_STACKNAME="$1" ;;
          --region)          shift; AWS_REGION="$1" ;;
          --resource)        shift; RESOURCE="$1" ;;
          --handle)          shift; WAIT_HANDLE="$1" ;;
          --config-sets)     shift; CONFIG_SETS="$1" ;;
          --banner)          shift ;;
          --enable-banner)   shift ;;
          *)                 echo "Ignoring argument '$1'" ;; # ignore
        esac
        shift
    done
}

function signal {
    local reason="$1"
    local code="${2:-1}"
    if [ "${reason}" != "" ]; then
        cfn-signal --exit-code "${code}" --reason "${reason}" "${WAIT_HANDLE}"
        return ${code}
    else
        cfn-signal --success 'true' "${WAIT_HANDLE}"
    fi
}

function install_cli {
    if [ $(which apt-get) != '' ]; then
        # (typically) Ubuntu
        apt-get update -y
        apt-get upgrade -y
        apt-get -y install awscli
        apt-get -y install python-setuptools
        easy_install "${CFN_BOOTSTRAP}"
        if [ ! -L /etc/init.d/cfn-hup ] && [ ! -e /etc/init.d/cfn-hup ]; then
            ln -s "/root/aws-cfn-bootstrap-latest/init/ubuntu/cfn-hup" "/etc/init.d/cfn-hup" 
        fi
        apt-get install -y dos2unix
    else
        # (typically) Red Hat derivative
        if [ $(which aws) != '' ]; then
            yum update -y aws-cfn-bootstrap
        else
            yum install -y dos2unix
            yum install -y unzip
            mkdir -p /tmp/aws-install/aws-cfn-bootstrap
            curl 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip' \  
                -o '/tmp/aws-install/awscli-bundle.zip'
            unzip /tmp/aws-install/awscli-bundle.zip -d /tmp/aws-install
            /tmp/aws-install/awscli-bundle/install --install-dir "/opt/aws"
            /opt/aws/bin/easy_install --script-dir "/opt/aws/bin" "${CFN_BOOTSTRAP}"
            yum remove -y unzip
            rm -rf /tmp/aws-install
        fi
    fi
}

function signal_completion {
    if [ "${WAIT_HANDLE}" == "" ]; then
        return 0
    fi
    # Trigger the cfn-init section of the 
    cfn-init --verbose --stack "${AWS_STACKNAME}" --region "${AWS_REGION}" \
        --resource "${RESOURCE}"  --configsets "${CONFIG_SETS}" || \
        return $(signal 'Failed to run cf-init' "$?")
    signal
}

get_parameters "$@"
install_cli || exit 1
signal_completion || exit 2
