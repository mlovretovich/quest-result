# set up local variables to be used for build/deployment
# 	* project name is propegated and used for application name throughout infrastructure
# 	* application version is derived from latest git tag + commit number
# 	* account id is dynamic and set via the users  

PROJECT_NAME = $(shell basename `pwd`)
PROJECT_VERSION = $(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query "Account" --output text)
AWS_REGION = $(shell aws configure get region)

build: 
	@git diff-index --quiet HEAD # git branch must be clean
	@docker build . -t $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(PROJECT_NAME):$(PROJECT_VERSION)

push: build
	@aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com && \
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(PROJECT_NAME):$(PROJECT_VERSION)

init:
	@cd terraform && \
	terraform init && \
	cd ..

plan:
	@cd terraform && \
	terraform plan -var app_name="$(PROJECT_NAME)" -var app_version="$(PROJECT_VERSION)" -var-file="default.tfvars" && \
	cd ..

apply:
	@cd terraform && \
	terraform apply -auto-approve -var app_name="$(PROJECT_NAME)" -var app_version="$(PROJECT_VERSION)" -var-file="default.tfvars" && \
	cd ..

deploy: build push apply

destroy:
	@cd terraform && \
		terraform destroy -auto-approve -var app_name="$(PROJECT_NAME)" -var app_version="$(PROJECT_VERSION)" -var-file="default.tfvars" && \
		cd ..