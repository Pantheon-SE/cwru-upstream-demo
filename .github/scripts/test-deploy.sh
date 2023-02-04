#!/bin/bash

# Usage
# ./live-deploy.sh <site-name or uuid>

# Exit on error
set -e

SITE=$1
DEV=$(echo "${SITE}.dev")
START=$SECONDS

# Tell slack we're starting this site
SLACK_START="Started ${SITE} Test deployment"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK_START}'}" $SLACK_WEBHOOK
echo -e "Starting ${SITE} Test Deployment";

# Deploy code to test and live
terminus env:deploy $TEST --cc --updatedb -n -q
SLACK="Finished ${SITE} TEST Deployment"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK}'}" $SLACK_WEBHOOK


# Report time to results.
DURATION=$(( SECONDS - START ))
TIME_DIFF=$(bc <<< "scale=2; $DURATION / 60")
MIN=$(printf "%.2f" $TIME_DIFF)
echo -e "Finished ${SITE} in ${MIN} minutes"
echo "${SITE},${ID},${MIN}" >> /tmp/results.txt

SITE_LINK="https://test-${SITE}.pantheonsite.io";
SLACK=":white_check_mark: Finished ${SITE} full deployment in ${MIN} minutes. \n ${SITE_LINK}"
curl -X POST -H 'Content-type: application/json' --data "{'text':'${SLACK}'}" $SLACK_WEBHOOK
