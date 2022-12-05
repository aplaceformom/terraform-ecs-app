/* vim: ts=2:sw=2:sts=0:expandtab */
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
locals {
  tags = merge(var.tags, { environment = terraform.workspace, env = terraform.workspace, name = var.name })

  region = data.aws_region.current.name

  environs = merge(var.environment, { environment = terraform.workspace })
  environ = [
    for key in sort(keys(local.environs)) : {
      name  = key
      value = local.environs[key]
    }
  ]

  secrets = [
    for key in sort(keys(var.secrets)) : {
      name      = key
      valueFrom = substr(var.secrets[key], 0, 8) == "arn:aws:" ? var.secrets[key] : substr(var.secrets[key], 0, 4) == "key/" ? "arn:aws:kms:${local.region}:${data.aws_caller_identity.current.account_id}:${var.secrets[key]}" : substr(var.secrets[key], 0, 1) == "/" ? "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/${replace(var.secrets[key], "/^[/]/", "")}" : "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${var.secrets[key]}"
    }
  ]

  xray = [{
    name  = "xray-daemon"
    image = "amazon/aws-xray-daemon"
    portMappings = [
      {
        containerPort = 2000
        protocol      = "udp"
      }
    ]
  }]

  template = [{
    name      = var.name
    image     = var.image
    command   = var.command
    essential = true
    portMappings = [{
      hostPort      = var.port
      containerPort = var.port
      protocol      = "tcp"
    }]
    environment = local.environ
    secrets     = local.secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-region        = local.region
        awslogs-group         = var.family
        awslogs-stream-prefix = var.prefix
      }
    }
  }]
}
