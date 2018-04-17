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

deployopts=""
if [ ! -z "$ACTOR_ID" ]; then
    deployopts="${deployopts} -U ${ACTOR_ID}"
fi

auth-tokens-refresh -S
echo "abaco deploy ${deployopts} ${@}"
abaco deploy ${@} ${deployopts}

