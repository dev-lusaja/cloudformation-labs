include ../base.mk

PROJECT_NAME = Lambda-Cloudformation

STACK_NAME 				= $$(uname -n)-lambda-container
STACK_NAME_LAMBDA 		= $(STACK_NAME)-function
STACK_NAME_ECR	 		= $(STACK_NAME)-hello-world-golang
IMAGE_ECR				= 417302926719.dkr.ecr.${DEPLOY_REGION}.amazonaws.com/$(STACK_NAME_ECR)

deploy: build deploy-ecr push deploy-lambda execute-lambda ## Deploy stack on AWS: make deploy

build:
	@docker build -t $(IMAGE_ECR):latest -f docker/Dockerfile .

push:
	@$$(aws ecr get-login --no-include-email --region $(DEPLOY_REGION))
	@docker push $(IMAGE_ECR)

up:
	@docker run $(IMAGE_ECR):latest

ssh:
	@docker run -it --rm $(IMAGE_ECR):latest /bin/sh

delete:
	@aws ecr batch-delete-image --repository-name $(STACK_NAME_ECR) --image-ids imageTag=latest
	@aws cloudformation delete-stack \
	--stack-name $(STACK_NAME_ECR) \
	--region ${DEPLOY_REGION}
	@aws cloudformation delete-stack \
	--stack-name $(STACK_NAME_LAMBDA) \
	--region ${DEPLOY_REGION}

deploy-ecr:
	@aws cloudformation deploy \
	--template-file ./cloudformation/ecr.yml \
	--stack-name $(STACK_NAME_ECR) \
	--parameter-overrides \
		ECRName=$(STACK_NAME_ECR) \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM

deploy-lambda:
	@aws cloudformation deploy \
	--template-file ./cloudformation/function.yml \
	--stack-name $(STACK_NAME_LAMBDA) \
	--parameter-overrides \
		FunctionName=$(STACK_NAME_LAMBDA) \
		ImageUri=$(IMAGE_ECR):latest \
	--region ${DEPLOY_REGION} \
	--capabilities CAPABILITY_NAMED_IAM

execute-lambda:
	@echo Executing lambda function...
	@aws lambda invoke --function-name $(STACK_NAME_LAMBDA) \
	--payload '{ "name": "HelloWorld" }' \
	/dev/stdout

zip: ## Generate .zip: make zip
	@echo generating .zip
	@mkdir -p $(PWD)/dist
	@zip -r -j ./dist/$(ZIP_NAME) ./src

code: zip ## Upload code to lambda function: make code
	@echo upload code for lambda function
	@aws s3 sync $(PWD)/dist s3://$(BUCKET_NAME)
	@rm -rf $(PWD)/dist