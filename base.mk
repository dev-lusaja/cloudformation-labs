.DEFAULT_GOAL := help

DEPLOY_REGION = us-east-1 # Virginia
DOMAIN = devlusaja.com
PROJECT_NAME_BASE = WebSite

deploy: ## Deploy stack on AWS: make deploy
	@echo starting deployment
	@aws cloudformation deploy \
	--template-file ./cloudformation/master.yml \
	--stack-name ${PROJECT_NAME} \
	--parameter-overrides \
		BucketName=$(BUCKET_NAME) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM
	@echo deployment completed
	@make sync-bucket

events: ## Show stack events: make events
	@aws cloudformation describe-stack-events  \
	--stack-name $(PROJECT_NAME) \
	--region ${DEPLOY_REGION} \

delete: delete-stack delete-bucket ## Delete full stack on AWS: make delete
	@echo deleted completed

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