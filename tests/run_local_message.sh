#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

detect_ci

source reactor.rc

TEMP=`mktemp -d $PWD/tmp.XXXXXX`
echo "Working out of $TEMP"

docker run -t -v ${HOME}/.agave:/root/.agave:rw \
           -v ${TEMP}:/mnt/ephemeral-01:rw \
           -e MSG='{"message": "Hi"}' \
           ${DOCKER_HUB_ORG}/${DOCKER_IMAGE_TAG}:${DOCKER_IMAGE_VERSION}

if [ "$?" == 0 ]; then
    rm -rf ${TEMP}
fi
