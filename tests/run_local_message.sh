#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

detect_ci

source reactor.rc

MESSAGE_PATH="data/intent.json"

MESSAGE=
if [ -f "${DIR}/${MESSAGE_PATH}" ]; then
    MESSAGE=$(<${DIR}/${MESSAGE_PATH})
fi

CUSTOM_RECIPIENT=
if [ ! -z "$1" ]; then
    CUSTOM_RECIPIENT=$1
fi

TEMP=`mktemp -d $PWD/tmp.XXXXXX`
echo "Working out of $TEMP"

if [ -z "$CUSTOM_RECIPIENT" ]; then

docker run -t -v ${HOME}/.agave:/root/.agave:rw \
           -v ${TEMP}:/mnt/ephemeral-01:rw \
           -e MSG='{"message": ${MESSAGE}}' \
           ${DOCKER_HUB_ORG}/${DOCKER_IMAGE_TAG}:${DOCKER_IMAGE_VERSION}

else

docker run -t -v ${HOME}/.agave:/root/.agave:rw \
           -v ${TEMP}:/mnt/ephemeral-01:rw \
           -e MSG='{"message": ${MESSAGE}}' \
           -e RECIPIENT="$CUSTOM_RECIPIENT" \
           ${DOCKER_HUB_ORG}/${DOCKER_IMAGE_TAG}:${DOCKER_IMAGE_VERSION}

fi

if [ "$?" == 0 ]; then
    rm -rf ${TEMP}
fi
