terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  ecr_repository_name = var.ecr_repository_name == null ? var.app_name : var.ecr_repository_name
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