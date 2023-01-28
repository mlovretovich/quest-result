terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


locals {
  instance_count        = 2
  fqdn                  = "quest.brotherhoodwithoutmanners.net" # fully qualified domain name
  lb_access_logs_bucket = "mlovretovich-lb-access-logs"
  ecr_repository        = var.app_name
  tags = {
    ProjectName    = var.app_name
    ProjectVersion = var.app_version
  }
}



module "network" {
  source   = "./modules/network"
  app_name = var.app_name

}


module "load_balancer" {
  source                = "./modules/load_balancer"
  subnet_ids            = [for subnet in module.network.subnets : subnet.id]
  vpc_id                = module.network.vpc_id
  app_name              = var.app_name
  fqdn                  = local.fqdn
  lb_access_logs_bucket = local.lb_access_logs_bucket

}

module "ecs_fargate_service" {
  source                = "./modules/ecs_fargate_service"
  subnet_ids            = [for subnet in module.network.subnets : subnet.id]
  vpc_id                = module.network.vpc_id
  app_name              = var.app_name
  app_version           = var.app_version
  fqdn                  = local.fqdn
  lb_access_logs_bucket = local.lb_access_logs_bucket
  lb_target_group_arn   = module.load_balancer.target_group_arn
  instance_count        = local.instance_count
  ecr_repository_name   = local.ecr_repository

}