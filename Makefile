create-sa:
	./src/infra/scripts/terraform_service_account.sh ${project} terraform ./secrets/service_account.json

delete-sa:
	gcloud iam service-accounts delete terraform@prow-handson.iam.gserviceaccount.com

enable-apis:
	./src/infra/scripts/enable_apis.sh

init:
	terraform init src/infra/terraform

plan:
	terraform plan src/infra/terraform

apply:
	terraform apply src/infra/terraform

destroy:
	terraform destroy src/infra/terraform

refresh:
	terraform refresh src/infra/terraform

get-cluster-credentials:
	gcloud container clusters get-credentials "$(TF_VAR_name)-cluster" --project="$(TF_VAR_project_id)" --zone="$(TF_VAR_location)"

generate-hmac-token:
	openssl rand -hex 20 > ./secrets/hmac-token

create-hmac-token-secrete:
	kubectl create secret generic hmac-token --from-file=hmac=./secrets/hmac-token

create-oauth-token-secrete:
	kubectl create secret generic oauth-token --from-file=oauth=./secrets/oauth-token

