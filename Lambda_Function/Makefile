include ../base.mk

PROJECT_NAME = Lambda-Cloudformation

STACK_NAME 				= $$(uname -n)-lambda
STACK_NAME_LAMBDA 		= $$(uname -n)-lambda-function
STACK_NAME_BUCKET 		= $$(uname -n)-lambda-bucket
BUCKET_NAME 			= $$(uname -n)-lambda-function-code
ZIP_NAME    			= code.zip

deploy: deploy-s3 code deploy-lambda execute-lambda ## Deploy stack on AWS: make deploy

delete:
	@aws s3 rm s3://$(BUCKET_NAME) --recursive
	@aws cloudformation delete-stack \
	--stack-name $(STACK_NAME_BUCKET) \
	--region ${DEPLOY_REGION}
	@aws cloudformation delete-stack \
	--stack-name $(STACK_NAME_LAMBDA) \
	--region ${DEPLOY_REGION}

deploy-s3:
	@aws cloudformation deploy \
	--template-file ./cloudformation/bucket.yml \
	--stack-name $(STACK_NAME_BUCKET) \
	--parameter-overrides \
		S3BucketName=$(BUCKET_NAME) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM

deploy-lambda:
	@aws cloudformation deploy \
	--template-file ./cloudformation/function.yml \
	--stack-name $(STACK_NAME_LAMBDA) \
	--parameter-overrides \
		S3Bucket=$(BUCKET_NAME) \
		S3Key=$(ZIP_NAME) \
		FunctionName=$(STACK_NAME_LAMBDA) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM

execute-lambda:
	@echo Executing lambda function...
	@aws lambda invoke --function-name $(STACK_NAME_LAMBDA) \
	--payload '{ "Hello": "World" }' \
	response.json

zip: ## Generate .zip: make zip
	@echo generating .zip
	@mkdir -p $(PWD)/dist
	@zip -r -j ./dist/$(ZIP_NAME) ./src

code: zip ## Upload code to lambda function: make code
	@echo upload code for lambda function
	@aws s3 sync $(PWD)/dist s3://$(BUCKET_NAME)
	@rm -rf $(PWD)/dist