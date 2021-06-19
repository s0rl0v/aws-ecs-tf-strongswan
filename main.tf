locals {
  name = "strongswan-vpn"
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.1.0"

  name = "${local.name}-ecs-cluster"

  container_insights = true

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]

  tags = var.default_tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = local.name
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "this" {
  family = local.name

  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.this.arn

  container_definitions = jsonencode([{
    name  = local.name
    image = "vimagick/strongswan"

    network_mode = "awsvpc"

    environment = [
      {
        name  = "VPN_DOMAIN"
        value = var.vpn_domain
      },
      {
        name  = "VPN_NETWORK"
        value = values(module.cidrs.network_cidr_blocks)[0]
      },
      {
        name  = "LAN_NETWORK"
        value = "192.168.0.0/16"
      },
      {
        name  = "VPN_P12_PASSWORD"
        value = random_password.this.result
      }
    ]

    portMappings = [
      {
        containerPort = 500
        hostPort      = 500
        protocol      = "udp"
      },
      {
        containerPort = 4500
        hostPort      = 4500
        protocol      = "udp"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-group         = local.name
        awslogs-stream-prefix = local.name
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name    = local.name
  cluster = module.ecs.ecs_cluster_id

  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
