include ../base.mk

PROJECT_NAME ?= Gateway-Lambda-$(PROJECT_NAME_BASE)
BUCKET_NAME ?= s3gtwlmbd.$(DOMAIN)
ZIP_NAME ?= code.zip

bucket:
	@aws cloudformation deploy \
	--template-file ./cloudformation/bucket.yml \
	--stack-name S3-${PROJECT_NAME} \
	--parameter-overrides \
		BucketName=$(BUCKET_NAME) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM
	@make code

deploy: bucket ## Deploy stack on AWS: make deploy
	@echo starting deployment
	@aws cloudformation deploy \
	--template-file ./cloudformation/master.yml \
	--stack-name ${PROJECT_NAME} \
	--parameter-overrides \
		S3Bucket=$(BUCKET_NAME)\
		S3Key=$(ZIP_NAME) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM
	@echo deployment completed

delete:
	@echo starting stack delete
	@aws cloudformation delete-stack \
	--stack-name $(PROJECT_NAME) \
	--region ${DEPLOY_REGION}
	@aws cloudformation delete-stack \
	--stack-name S3-${PROJECT_NAME} \
	--region ${DEPLOY_REGION}

zip: ## Generate .zip: make zip
	@echo generating .zip
	@mkdir -p dist
	@zip -r -j ./dist/$(ZIP_NAME) ./src

code: zip ## Upload code to lambda function: make code
	@echo upload code for lambda function
	@aws s3 sync $(PWD)/dist s3://$(BUCKET_NAME)
	@rm -rf $(PWD)/dist