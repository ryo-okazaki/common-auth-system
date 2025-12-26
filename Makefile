############################
# Local Docker Compose
############################

up:
	docker compose --env-file .env -f compose.auth.local.yaml up -d --build
	docker compose --env-file .env -f compose.mail.local.yaml up -d --build

down:
	docker compose --env-file .env -f compose.auth.local.yaml down
	docker compose --env-file .env -f compose.mail.local.yaml down

rebuild:
	docker compose --env-file .env -f compose.auth.local.yaml down
	docker compose --env-file .env -f compose.auth.local.yaml up -d --build

bash-tools:
	docker compose --env-file .env -f compose.auth.local.yaml exec auth-kc-tools sh

export-settings:
	docker compose --env-file .env -f compose.auth.local.yaml exec auth-kc-tools bash -c "cd /opt/keycloak/exports/scripts && bash export-realm.sh"

export-settings-details:
	docker compose --env-file .env -f compose.auth.local.yaml exec auth-kc-tools bash -c "cd /opt/keycloak/exports/scripts && bash export-realm-details.sh"


############################
# Common Modules
############################
tf-fmt-mods:
	terraform -chdir=terraform/modules fmt

############################
# Remote Backend
############################
tf-init-backend:
	terraform -chdir=terraform/remote-backend init

tf-fmt-backend:
	terraform -chdir=terraform/remote-backend fmt

tf-vali-backend:
	terraform -chdir=terraform/remote-backend validate

tf-plan-backend:
	terraform -chdir=terraform/remote-backend plan

tf-apply-backend:
	terraform -chdir=terraform/remote-backend apply

############################
# Development infrastructure Environment
############################
tf-init-dev:
	terraform -chdir=terraform/environments/development/infrastructure init -backend-config=development.tfbackend

tf-fmt-dev:
	terraform -chdir=terraform/environments/development/infrastructure fmt

tf-vali-dev:
	terraform -chdir=terraform/environments/development/infrastructure validate

tf-plan-dev:
	terraform -chdir=terraform/environments/development/infrastructure plan -var-file=terraform.tfvars

tf-apply-dev:
	terraform -chdir=terraform/environments/development/infrastructure apply -var-file=terraform.tfvars

tf-destroy-dev:
	terraform -chdir=terraform/environments/development/infrastructure destroy -var-file=terraform.tfvars

tf-out-dev:
	terraform -chdir=terraform/environments/development/infrastructure output

tf-state-dev:
	terraform -chdir=terraform/environments/development/infrastructure state list

############################
# Development Keycloak Environment
############################
tf-init-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak init -backend-config=development.tfbackend

tf-fmt-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak fmt

tf-vali-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak validate

tf-plan-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak plan -var-file=terraform.tfvars

tf-apply-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak apply -var-file=terraform.tfvars

tf-out-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak output

tf-state-kc-dev:
	terraform -chdir=terraform/environments/development/keycloak state list
