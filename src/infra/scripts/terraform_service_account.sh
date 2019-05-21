#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

if [ "$#" -ne 3 ]; then
 echo "usage: $0 <project-id> <service-account-name> <key-path>"
 exit 1
fi

PROJECT_ID=$1
SERVICE_ACCOUNT=$2
KEY_PATH=$3

gcloud iam service-accounts create ${SERVICE_ACCOUNT} --display-name "Terraform admin account"
gcloud iam service-accounts keys create ${KEY_PATH} --iam-account ${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/owner
