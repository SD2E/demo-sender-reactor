#!/usr/bin/env bash

# Invoke code for a Reactor in an environment
# that closely emulates the Abaco runtime

# Required Globals
#   None
# Optional Globals
#   REACTOR_RC
#   REACTOR_RUN_OPTS
#   REACTOR_USE_TMP
#   REACTOR_CLEANUP_TMP
#   REACTOR_OVERRIDE_LOCAL
#   CONTAINER_REPO
#   CONTAINER_TAG
#   AGAVE_CACHE_DIR
#   REACTOR_JOB_DIR
#
# Required inputs
#   MESSAGE - File containing JSON message body
#   CONFIG - Reactor config file (reactor.rc)


COMMANDS="$@"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/common.sh"

if [ -z "$REACTOR_RC" ]; then
    REACTOR_RC="reactor.rc"
fi
if [ -f ${REACTOR_RC} ]; then
    source ${REACTOR_RC}
else
    echo "Missing reactor variables file ${REACTOR_RC}"
    exit 1
fi

# Inherited from REACTOR_RC
# TODO: Allow override by ENV
CONTAINER_IMAGE="$DOCKER_HUB_ORG/${DOCKER_IMAGE_TAG}:${DOCKER_IMAGE_VERSION}"

if [ -z "${CONTAINER_IMAGE}" ]; then
    echo "Usage: $(basename $0) <container_image>" &&
    exit 1
fi

# Api integration
AGAVE_CREDS="${AGAVE_CACHE_DIR}"
if [ ! -d "${AGAVE_CREDS}" ]; then
    AGAVE_CREDS="${HOME}/.agave"
fi
if [ ! -f "${AGAVE_CREDS}/current" ]; then
    die "No API credentials found in ${AGAVE_CREDS}"
fi

# Emphemeral directory
#  Can be specified with REACTOR_JOB_DIR
#  Can be turned off with REACTOR_NO_TMP=1
WD=${PWD}
TEMP=""
if ((REACTOR_USE_TMP )); then
    if [ ! -z "${REACTOR_JOB_DIR}" ]; then
        rm -rf "${REACTOR_JOB_DIR}";
        mkdir -p "${REACTOR_JOB_DIR}"
        TEMP=${REACTOR_JOB_DIR}
    else
        TEMP=`mktemp -d $PWD/tmp.XXXXXX`
    fi
    WD=${TEMP}
fi
log "Working directory: ${WD}"

# Volume mounts
MOUNTS="-v ${WD}:/mnt/ephemeral-01"
if [ -d "${AGAVE_CREDS}" ]; then
    MOUNTS="$MOUNTS -v ${AGAVE_CREDS}:/root/.agave:rw"
fi

envopts=""
if ((! REACTOR_OVERRIDE_LOCAL )); then
    envopts="${envopts} -e LOCALONLY=1"
fi

# Tweak config for Docker depending on if we're running under CI
dockeropts="${REACTOR_RUN_OPTS}"
detect_ci
if ((UNDER_CI)); then
  # If running a Dockerized process with a volume mount
  # written files will be owned by root and unwriteable by
  # the CI user. We resolve this by setting the group, which
  # is the same approach we use in the container runner
  # that powers container-powered Agave jobs
  dockeropts=" --user=0:${CI_GID}"
fi

docker run -t ${dockeropts} ${envopts} ${MOUNTS} ${CONTAINER_IMAGE} ${@}

# Clean up: Set permissions and ownership on volume mount
if ((UNDER_CI)); then
    docker run ${dockeropts} -t -v ${WD}:/mnt/ephemeral-01 -w /mnt/ephemeral-01 ${CONTAINER_IMAGE} find . -type d -exec chmod 0777 {} \;
    docker run ${dockeropts} -t -v ${WD}:/mnt/ephemeral-01 -w /mnt/ephemeral-01 ${CONTAINER_IMAGE} find . -type f -exec chmod 0666 {} \;
    docker run ${dockeropts} -t -v ${WD}:/mnt/ephemeral-01 -w /mnt/ephemeral-01 ${CONTAINER_IMAGE} find . -exec chown ${CI_UID}:${CI_GID} {}
    if ((REACTOR_CLEANUP_TMP)) && [ -z "${TEMP}" ]; then
        log "Cleaning up ${TEMP}"
        rm -rf ${TEMP}
    fi
fi
