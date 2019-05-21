#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

gcloud beta billing projects link ${PROJECT_ID} --billing-account ${BILLING_ACCOUNT_ID}

gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable container.googleapis.com
