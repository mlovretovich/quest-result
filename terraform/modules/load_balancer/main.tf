# setup local variables 
locals {

  # get hosted zone from input domain
  fqdn        = split(".", var.fqdn)
  hosted_zone = join(".", [local.fqdn[length(local.fqdn) - 2], local.fqdn[length(local.fqdn) - 1]])
  host        = local.fqdn[length(local.fqdn) - 3]

  # setup access logs s3 bucket variable 
  lb_access_logs_bucket = var.lb_access_logs_bucket
}

# get hosted zone info
# 
data "aws_route53_zone" "main" {
  name         = local.hosted_zone
  private_zone = false
}

# get default security group for vpn
#
data "aws_security_group" "default" {
  vpc_id = var.vpc_id
  # vpc_id = aws_vpc.main.id 
  name = "default"
}

resource "aws_acm_certificate" "main" {
  domain_name       = var.fqdn
  validation_method = "DNS"
}

# create dns records for certificate validation
#
resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# setup certificate validation using dns records
#
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}

# create security groups 
#
resource "aws_security_group" "lb_sg_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# create load balancer, listeners for each port, and target group
#
resource "aws_lb" "main" {
  name               = "${var.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id, aws_security_group.lb_sg_https.id, data.aws_security_group.default.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  access_logs {
    bucket  = local.lb_access_logs_bucket
    prefix  = "${var.app_name}-lb"
    enabled = true
  }

}

resource "aws_lb_target_group" "main" {
  name        = "${var.app_name}-lb-http-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    enabled             = true
    port                = 3000
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "front_end_tls" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


# add a dns record for this load balancer in the hosted zone
#
resource "aws_route53_record" "host" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.host
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
