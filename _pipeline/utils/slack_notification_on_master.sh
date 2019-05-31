#!/bin/bash
source "/opt/sb/sb-pipeline.sh"
set -e

 # Notify 'release' that the release is finished
if [[ "${ENVIRONMENT}" == "live" ]] && [[ "${BRANCH_NAME}" == 'master' ]]; then
    slack_notification $1 release $2 "$3"
fi
