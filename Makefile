VAULT_PWD   := .vault-password
VAULT_FILE  := ansible/group_vars/all/vault.yml
TF_DIR      := terraform
ANSIBLE_DIR := ansible

# HMAC-ключи для S3-backend нужны как env vars (backend.tf не читает .tfvars).
# Остальные TF-переменные генерируются в terraform/secrets.auto.tfvars через make tfvars.
VAULT_DUMP := ansible-vault view --vault-password-file $(VAULT_PWD) $(VAULT_FILE)

export AWS_ACCESS_KEY_ID     := $(shell $(VAULT_DUMP) | awk '/^vault_tf_state_access_key:/ {print $$2}')
export AWS_SECRET_ACCESS_KEY := $(shell $(VAULT_DUMP) | awk '/^vault_tf_state_secret_key:/ {print $$2}')

.PHONY: tfvars init plan apply destroy output console fmt validate \
        gen-inventory ansible-install setup deploy ping \
        edit-vault view-vault

# ───── Ansible → Terraform (генерация tfvars) ─────
tfvars:
	cd $(ANSIBLE_DIR) && ansible-playbook render-tfvars.yml

# ───── Terraform ─────
init: tfvars
	cd $(TF_DIR) && terraform init

plan: tfvars
	cd $(TF_DIR) && terraform plan

apply: tfvars
	cd $(TF_DIR) && terraform apply

destroy: tfvars
	cd $(TF_DIR) && terraform destroy

output:
	cd $(TF_DIR) && terraform output

console: tfvars
	cd $(TF_DIR) && terraform console

fmt:
	cd $(TF_DIR) && terraform fmt -recursive

validate: tfvars
	cd $(TF_DIR) && terraform validate

# ───── Ansible (деплой приложения) ─────
gen-inventory:
	@./scripts/gen-inventory.sh

ansible-install:
	cd $(ANSIBLE_DIR) && ansible-galaxy install -r requirements.yml

setup: ansible-install
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags setup

deploy:
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags deploy

ping:
	cd $(ANSIBLE_DIR) && ansible all -m ping

# ───── Vault ─────
edit-vault:
	ansible-vault edit --vault-password-file $(VAULT_PWD) $(VAULT_FILE)

view-vault:
	ansible-vault view --vault-password-file $(VAULT_PWD) $(VAULT_FILE)
