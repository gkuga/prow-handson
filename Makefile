create-terraform-sa:
	./src/infra/scripts/terraform_service_account.sh ${TF_VAR_project_id} terraform ./secrets/terraform_service_account.json

delete-terraform-sa:
	gcloud iam service-accounts delete terraform@${TF_VAR_project_id}.iam.gserviceaccount.com

generate-prow-sa-key:
	./src/infra/scripts/prow_service_account_key.sh ${TF_VAR_project_id} prow-ci ./secrets/prow_service_account.json

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

update-plugins: get-cluster-credentials
	kubectl create configmap plugins --from-file=plugins.yaml=./src/infra/manifests/plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -

update-config: get-cluster-credentials
	kubectl create configmap config --from-file=config.yaml=./src/infra/manifests/config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

generate-hmac-token:
	openssl rand -hex 20 > ./secrets/hmac-token

create-hmac-token-secrete:
	kubectl create secret generic hmac-token --from-file=hmac=./secrets/hmac-token

create-oauth-token-secrete:
	kubectl create secret generic oauth-token --from-file=oauth=./secrets/oauth-token

create-prow-sa-key-secrete:
	kubectl create secret generic prow-sa-key --from-file=service-account.json=./secrets/prow_service_account.json -n test-pods

create-ssh-key-secret:
	kubectl create secret generic ssh-key --from-file=./secrets/ssh-key -n test-pods 

check-conf:
	./bin/checkconfig-darwin-amd64 --plugin-config=src/infra/manifests/plugins.yaml --config-path=src/infra/manifests/config.yaml

test:
	go test -v ./src/apps/hello/...

build:
	go build -o hello -v ./src/apps/hello/...
