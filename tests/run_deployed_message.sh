#!/usr/bin/env bash

if [[ -z "$DIR" ]]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

MESSAGE_PATH="data/tests-deployed-message.json"

# Load ACTOR_ID from env or disk
ACTOR_ID="${1}"
if [ -z "${ACTOR_ID}" ];  then
    if [ -f ".ACTOR_ID" ]; then
        ACTOR_ID=$(cat .ACTOR_ID)
    fi
fi
if [ -z "${ACTOR_ID}" ]
then
    echo "Usage: $(basename $0) [ACTORID]"
    exit 1
fi

MESSAGE=
if [ -f "${DIR}/${MESSAGE_PATH}" ]; then
    # MESSAGE=$(cat ${DIR}/${MESSAGE_PATH}})
    MESSAGE=$(<${DIR}/${MESSAGE_PATH})
fi

if [ -z "${MESSAGE}" ]; then
    echo "Message not readable \@ ${MESSAGE_PATH}"
    exit 1
fi

# MESSAGE='{"to": "matt.vaughn@gmail.com", "subject": "Hello, computer.", "body":"A keyboard... how quaint."}'

MAX_ELAPSED=100 # Maximum duration for any async task
INITIAL_PAUSE=1 # Initial delay
BACKOFF=2 # Exponential backoff

TS1=$(date +%s)
TS2=
ELAPSED=0
PAUSE=${INITIAL_PAUSE}
EXC_STATUS=

echo "abaco run -v -m \"${MESSAGE}\" ${ACTOR_ID}"

#set -x
#abaco run -v -m "${MESSAGE}" ${ACTOR_ID}
#set +x

EXEC=$(abaco run -v -m "${MESSAGE}" ${ACTOR_ID})
EXEC_ID=$(echo ${EXEC} | jq -r .result.executionId)
# echo ${EXEC}
echo "Execution ${EXEC_ID}"

while [[ "${EXC_STATUS}" != "COMPLETE" ]]
do
    TS2=$(date +%s)
    ELAPSED=$(($TS2 - $TS1))
    EXC_STATUS=$(abaco executions -v ${ACTOR_ID} ${EXEC_ID}  | jq -r .result.status)
    if [[ "${ELAPSED}" -ge "${MAX_ELAPSED}" ]]
    then
        break
    fi
    printf "Wait " ; printf "%0.s." $(seq 1 ${PAUSE}); printf "\n"
    sleep $PAUSE
    PAUSE=$(($PAUSE * $BACKOFF))
done

echo " ${ELAPSED} seconds"

if [ "${EXC_STATUS}" == "COMPLETE" ]
then
    abaco logs ${ACTOR_ID} ${EXEC_ID}
    exit 0
else
    echo "Error or Actor ${ACTOR_ID} couldn't process message"
    exit 1
fi
