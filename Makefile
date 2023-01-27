# set up local variables to be used for build/deployment
# 	* project name is propegated and used for application name throughout infrastructure
# 	* application version is derived from latest git tag + commit number
# 	* account id is dynamic and set via the users  

PROJECT_NAME = $(shell basename `pwd`)
PROJECT_VERSION = $(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query "Account" --output text)
AWS_REGION = $(shell aws configure get region)



build: 
	@docker build . -t $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(PROJECT_NAME):$(PROJECT_VERSION)

push: build
	@aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com && \
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(PROJECT_NAME):$(PROJECT_VERSION)
