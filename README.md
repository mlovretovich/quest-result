# A Quest In The Clouds: Results
Results of my quest in the cloud

![quest](https://user-images.githubusercontent.com/2027534/215284609-361c15ff-8ee1-4f98-a543-8b5bf51091c7.gif)

## URLs
* https://quest.thisistheway.fyi/
* https://quest.thisistheway.fyi/docker
* https://quest.thisistheway.fyi/secret_word
* https://quest.thisistheway.fyi/loadbalanced
* https://quest.thisistheway.fyi/tls

## What did I do?

- [X] Start a git repository. 
- [X] Deploy the app in the public cloud (Amazon).
- [X] Deploy the app in a Docker container. [^1]
- [X] Inject an Environment variable (SECRET_WORD) in the Docker container. 
- [X] Deploy a load balancer in front of the app.
- [X] Use Infrastructure as Code (IaC) to "codify" your deployment (Terraform).
- [X] Add TLS (https).

[^1]: I am considering this complete even though the application does not pass it's "docker" check. I assume this is due to the FARGATE platform not being compatible or granting access to check the docker daemon. I don't have access to the application source code so I cannot debug this further.

## How did I do it?
* I deployed the application on the Amazon Cloud's FARGATE serverless platform for containers. I chose FARGATE due to it's ability to run containers while creating minimal AWS resources. 
* I used Terraform to codify the environment. 
* I created a simple Makefile to simplfy the bringing up and down the environment. 

## Components

### Makefile
The application is built and deployed using make commands. 

#### Requirements
| Name | Version |
| ---- | ------- | 
| [terraform](https://www.terraform.io/) | 1.3 | 
| [awscli](https://aws.amazon.com/cli/) | 2.9 | 
| [docker](https://www.docker.com/) | 20 | 

#### Commands
| Command | Notes |
| ------- | ----- |
| ```make build``` | builds docker image named after the project. |
| ```make push``` |  pushes docker container to ECR Repository. |
| ```make init``` |  initializes terraform environment and installs required provider and modules |
| ```make plan``` |  outputs a terraform plan based on current state and changes|
| ```make deploy``` |  builds, pushes, and applys the terraform plan for the current app version |
| ```make destroy``` |  tears down all infrastructure |

##### Example 
```sh
$ make build
```
### Terraform
The terraform in this project will bring up a VPC and most resources required to run this application in the Amazon Cloud. 
#### Requirements
This terraform relies on the following resources to be present within the the AWS account.
* A Route53 Zone for the FQDN.
* An ECR Repository for the docker container. This *must* be named after the project name.
* A S3 bucket for the load balancer's access logs

#### Modules
I created 3 terraform modules in order to encapsulate resources and separate concerns. They are specific to this project and mainly used for readability purposes.
* [ecs_fargate_service](terraform/modules/ecs_fargate_service/README.md)
* [load_balancer](terraform/modules/load_balancer/README.md)
* [network](terraform/modules/network/README.md)

#### Variables
| Name | Type | Required? | Notes |
| ---- | ---- | --------- | ----- | 
| app_name | string | Yes | The app_name variable is set in the Makefile based on the project's directory name | 
| app_version | string | Yes | The app_version variable is set in the Makefile based on the current git tag + commit number |
| tags | map(string) | No | Map of tags to apply to taggable resources. By default ProjectName and ProjectVersion are set but tags can be added here as needed |
| fqdn | string | Yes | Fully qualified domain name |
| instance_count | number | Yes| number of instances to run on ECS |
| lb_access_logs_bucket | string | Yes | s3 bucket for load balancer's access logs |


#### Usage
set variables in terraform/default.tfvars
```
instance_count        = [number]
fqdn                  = [domain] # fully qualified domain name
lb_access_logs_bucket = [bucket]
```

main.tf
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  ecr_repository_name = var.app_name
  tags = merge(var.tags, { 
    ProjectName    = var.app_name
    Version = var.app_version
  } )
}

module "network" {
  source   = "./modules/network"
  app_name = var.app_name
  tags                = local.tags
}

module "load_balancer" {
  source                = "./modules/load_balancer"
  subnet_ids            = [for subnet in module.network.subnets : subnet.id]
  vpc_id                = module.network.vpc_id
  app_name              = var.app_name
  fqdn                  = var.fqdn
  lb_access_logs_bucket = var.lb_access_logs_bucket
  tags                  = local.tags
}

module "ecs_fargate_service" {
  source              = "./modules/ecs_fargate_service"
  subnet_ids          = [for subnet in module.network.subnets : subnet.id]
  vpc_id              = module.network.vpc_id
  app_name            = var.app_name
  app_version         = var.app_version
  lb_target_group_arn = module.load_balancer.target_group_arn
  instance_count      = var.instance_count
  ecr_repository_name = local.ecr_repository_name
  tags                = local.tags
}
```
</details>

## Given more time, I would improve...
There are a number of changes I would make to this project given time. 
1. it does bother me that the docker check does not pass. If this were a hard requirement and I am unable to debug the source code I would include a version of the application that runs on a simple ec2 instance.
2. Add further network security. The Application should not need public IP addresses but for some reason I could not get it to pass health checks with a private IP. It's difficult to debug through without source code.
3. Set up a remote backend for the terrform state
4. I would make the application environment aware. staging/qa/production environments created using aws organizations separate accounts. 
5. Add Auto-Scaling for service tasks
6. CI/CD with my preferred git flow:
	- git actions to include terraform plans on pull requests
	- commits to main trigger a deployment into the staging environment
	- pushed tags trigger a deployment into the production environment. 
7. Setup application logging
	- create cloudwatch log group
	- create AWS Openserch log group subscription for kibana
8. Continue to make modules more re-usable by adding variables to cover more use cases.
	





