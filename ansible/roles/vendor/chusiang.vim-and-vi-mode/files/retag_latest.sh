#!/bin/bash
# ============================================================
#  Author: Chu-Siang Lai / chusiang (at) drx.tw
#  Filename: retag_latest.sh
#  Modified: 2018-01-11 10:31
#  Description: Create docker tags of `latest`.
# ============================================================

DOCKER_IMAGE="chusiang/vim-and-vi-mode"
DOCKER_TAG="ubuntu16.04"

echo '===> Pull current image ...'
docker pull $DOCKER_IMAGE:$DOCKER_TAG
echo

echo '===> Tag current image to latest ...'
docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:latest
echo

echo '===> Push the latest tag ...'
docker push $DOCKER_IMAGE:latest
echo

echo '===> Remove old image ...'
docker rmi $(docker images | grep $DOCKER_IMAGE | grep '<none>' | awk '{ print $3 }')
