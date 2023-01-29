# ecs_fargate_service

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- | 
| app_name | string | The name of the application. This is used to namespace resources created. |
| app_version | string | The version of the container that should be run and declared in the task definition |
| ecr_repository_name | string | ECR repository for container image | 
| vpc_id | string | id of the VPC for the network resouces of this service |
| subnet_ids | list(string) | list of subnets available to spin up tasks |
| instance_count | number | number of desired tasks for this service  |
| lb_target_group_arn | string | ARN of the load balancer's target group that the tasks should register with | 


## Usage

```hcl
module "ecs_fargate_service" {
  source                = "./modules/ecs_fargate_service"
  subnet_ids            = [subnet_ids]
  vpc_id                = [vpc_id]
  app_name              = [app_name]
  app_version           = [app_version]
  lb_target_group_arn   = [lb_target_group_arn]
  instance_count        = [instance_count]
  ecr_repository_name   = [ecr_repository_name]

}

```