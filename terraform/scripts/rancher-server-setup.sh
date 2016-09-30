#!/bin/bash
###############################################################################
#  Name: rancher-server-setup.sh
#  Creation Date: 4/14/2016
#  Original Author: John Rowe (john.rowe@aquilent.com)
#
# Description: Sets up a host to be used for Rancher Server (http://rancher.com/rancher/)
###############################################################################

# By default we'll  use the latest container unless told otherwise
RANCHER_TAG="latest"

# Grab our RDS information
while getopts p:r:t:u: opt; do
    case ${opt} in
        p) RDS_PASS=${OPTARG}
            ;;
        r) RDS_HOST=${OPTARG}
            ;;
        t) RANCHER_TAG=${OPTARG}
            ;;
        u) RDS_USER=${OPTARG}
            ;;
    esac
done
LOGFILE=/var/log/rancher-server-setup.log

# Save standard output and standard error
exec 3>&1 4>&2
# Redirect standard output to a log file
exec 1>>$LOGFILE
# Redirect standard error to a log file
exec 2>&1

###############################################################################
# SETUP THE HOST
###############################################################################
# Make sure everything is up to date
aptitude update && aptitude upgrade -y
# install and setup lvm
aptitude install lvm2 -y
# Test to make sure the EBS volume is attached
while [ ! -e /dev/xvdd ] ; do
   echo "/dev/xvdd not mounted yet which is required for the LVM"
   echo "sleeping for 30 seconds"
   sleep 30
done
# Create the Volume Group
# Check to make sure it doesn't already exist
vgdisplay docker >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    vgcreate docker /dev/xvdd
fi
if [ $? -ne 0 ] ; then
    echo "ERROR: vgcreate on /dev/xvdd failed"
    exit 1
fi
# Find out how many extends we're dealing with
EXTENDS=$(vgdisplay -c docker | cut -d: -f 16)
# Create the LVM
# make sure it doesn't already exist
lvdisplay /dev/docker/data >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    lvcreate -l "${EXTENDS}" -n data docker
fi
if [ $? -ne 0 ] ; then
    echo "ERROR: lvcreate on docker VG failed"
    exit 1
fi
# Create the File System
# ensure it's not alreay mounted
grep "docker ext4" /proc/mounts >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
mkfs.ext4 /dev/docker/data
    if [ $? -ne 0 ] ; then
        echo "ERROR: Filesystem creation on /dev/docker/data failed!"
        exit 1
    fi

    # make sure it comes up across reboots, then mount it
    echo "/dev/docker/data   /var/lib/docker auto    defaults,nobootwait,noatime,nodiratime  0 0" | tee -a /etc/fstab
    if [ ! -d /var/lib/docker ] ; then
        mkdir -p /var/lib/docker
    fi
    mount /var/lib/docker
    if [ $? -ne 0 ] ; then
        echo "ERROR: Could not mount /dev/docker/data to /var/lib/docker!"
        exit 1
    fi
fi

###############################################################################
# Install Docker
###############################################################################
# Install dependencies
apt-get install apt-transport-https ca-certificates -y
apt-get install "linux-image-extra-$(uname -r)" -y
# Import GPG Keys
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# Add the Docker Repository
grep "dockerproject" /etc/apt/sources.list.d/docker >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee -a /etc/apt/sources.list.d/docker.list
fi
# Update Apt with the new repo
aptitude update
# Install the Docker Package; also lock the version to 1.10.3 as that is the latest rancher supports
aptitude install docker-engine=1.10.3-0~trusty -y
# Start the Rancher server if it's not already
docker inspect manager >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    docker run -d --restart=always -p 8080:8080 \
        --name manager \
        -e CATTLE_DB_CATTLE_MYSQL_HOST="${RDS_HOST}" \
        -e CATTLE_DB_CATTLE_MYSQL_PORT="${RDS_PORT}" \
        -e CATTLE_DB_CATTLE_MYSQL_NAME="${RDS_NAME}" \
        -e CATTLE_DB_CATTLE_USERNAME="${RDS_USER}" \
        -e CATTLE_DB_CATTLE_PASSWORD="${RDS_PASS}" \
        rancher/server:"${RANCHER_TAG}"
fi
