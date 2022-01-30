.DEFAULT_GOAL := help

DEPLOY_REGION  = us-east-1
USERNAME_LOCAL = "$(shell whoami)"
HASH           = $$(date +%s)

hash:
	echo $(HASH)

create_stack: ## Deploy stack on AWS: make deploy
	@echo starting deployment
	@aws cloudformation deploy \
	--template-file $(CLOUDFORMATION_TEMPLATE) \
	--stack-name ${STACK_NAME} \
	--parameter-overrides $(PARAMETERS) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM
	@echo deployment completed
	#@make sync-bucket

remove_stack:
	@echo starting stack delete
	@aws cloudformation delete-stack \
	--stack-name $(STACK_NAME) \
	--region ${DEPLOY_REGION}

events: ## Show stack events: make events
	@aws cloudformation describe-stack-events  \
	--stack-name $(PROJECT_NAME) \
	--region ${DEPLOY_REGION}

delete-stack:
	@echo starting stack delete
	@aws cloudformation delete-stack \
	--stack-name $(PROJECT_NAME) \
	--region ${DEPLOY_REGION}

delete-bucket:
	@echo starting bucket delete
	@aws s3 rb s3://$(BUCKET_NAME) --force

sync-bucket: ## Sync data with the bucket: make sync-bucket
	@echo starting sync bucket
	@aws s3 sync ./public s3://$(BUCKET_NAME) --acl public-read

help:
	@printf "\033[31m%-22s %-59s %s\033[0m\n" "Target" " Help" "Usage"; \
	printf "\033[31m%-22s %-59s %s\033[0m\n"  "------" " ----" "-----"; \
	grep -hE '^\S+:.*## .*$$' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' | sort | awk 'BEGIN {FS = ":"}; {printf "\033[32m%-22s\033[0m %-58s \033[34m%s\033[0m\n", $$1, $$2, $$3}'