PROJECT_NAME = static-web-site
BUCKET_NAME = aws.devlusaja.com # your domain
DEPLOY_REGION = us-east-1 # Virginia

deploy:
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

events:
	@aws cloudformation describe-stack-events  \
	--stack-name $(PROJECT_NAME) \
	--region ${DEPLOY_REGION} \

delete: delete-stack delete-bucket
	@echo deleted completed

delete-stack:
	@echo starting stack delete
	@aws cloudformation delete-stack \
	--stack-name $(PROJECT_NAME) \
	--region ${DEPLOY_REGION}

delete-bucket:
	@echo starting bucket delete
	@aws s3 rb s3://$(BUCKET_NAME) --force

sync-bucket:
	@echo starting sync bucket
	@aws s3 sync ./public s3://$(BUCKET_NAME) --acl public-read