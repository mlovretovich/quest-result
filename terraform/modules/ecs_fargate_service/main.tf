# get default security group
#
data "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name = "default"
}

data "aws_ecr_repository" "main" {
  name = var.ecr_repository_name
}

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# create IAM task role permissions to pull docker image and log to cloudwatch
#
resource "aws_iam_role" "task_role" {
  name = "ecs-task-${var.app_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name = "my_inline_policy"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource : "*"
        },
      ]
    })
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_role.arn
  container_definitions = jsonencode([{
    name      = "${var.app_name}",
    image     = "${data.aws_ecr_repository.main.repository_url}:${var.app_version}",
    cpu       = 0,
    essential = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        appProtocol   = "http"
      }
    ]
    }
  ])
}

# defines ecs fargate service
#
resource "aws_ecs_service" "main" {
  name                 = var.app_name
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.main.id
  desired_count        = var.instance_count
  force_new_deployment = false
  launch_type          = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = [data.aws_security_group.default.id]
  }
  deployment_circuit_breaker {
    enable   = false
    rollback = true
  }
  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.app_name
    container_port   = 3000
  }

}