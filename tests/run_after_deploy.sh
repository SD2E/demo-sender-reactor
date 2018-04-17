#!/usr/bin/env bash

if [ -z "$REACTOR_RC" ]; then
    REACTOR_RC="reactor.rc"
fi
if [ -f ${REACTOR_RC} ]; then
    source ${REACTOR_RC}
else
    echo "Missing reactor variables file ${REACTOR_RC}"
    exit 1
fi

ACTOR_ID=
if [ -f ".ACTOR_ID" ]; then
    ACTOR_ID=$(cat .ACTOR_ID)
fi

echo "Set alias ${REACTOR_ALIAS}"
syd add ${REACTOR_ALIAS} ${ACTOR_ID}
syd acl ${REACTOR_ALIAS} world --read

echo "Set permission for ${ACTOR_ID}"
abaco share -u world -p EXECUTE ${ACTOR_ID}
