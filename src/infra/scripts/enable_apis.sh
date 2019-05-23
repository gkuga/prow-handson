#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

gcloud beta billing projects link ${TF_VAR_project_id} --billing-account ${TF_VAR_billing_account_id}

gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable container.googleapis.com
