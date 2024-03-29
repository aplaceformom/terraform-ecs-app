/* vim: ts=2:sw=2:sts=0:expandtab */
locals {
  enable_app = "${local.lb_protocol == "" && var.enable ? true : false}"

  ##
  # if var.container_definitions != "" then:
  #  local.container_definitions = var.container_definitions
  # else:
  #  local.container_definitions = tostring(jsonencode(local.template))
  container_definitions = var.container_definitions != "" ? var.container_definitions : tostring(jsonencode(concat(local.template, var.xray ? local.xray : [])))
}

# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "app" {
  count       = local.enable_app ? 1 : 0
  name_prefix = local.prefix
  description = "controls access to app"
  vpc_id      = local.vpc_id
  tags        = local.tags

  ingress {
    protocol    = "tcp"
    from_port   = var.port
    to_port     = var.port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "ec2" {
  count                    = var.enable && local.launch_type == "EC2" ? 1 : 0
  family                   = local.family
  network_mode             = "awsvpc"
  requires_compatibilities = [local.launch_type]
  cpu                      = local.cpus
  memory                   = local.memory
  execution_role_arn       = local.exec_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = local.container_definitions

  volume {
    name = "${var.name}-data"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "cloudstor:aws"
    }
  }

  volume {
    name = "${var.name}-conf"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "cloudstor:aws"
    }
  }

  volume {
    name = "${var.name}-logs"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "cloudstor:aws"
    }
  }
}

resource "aws_ecs_task_definition" "fargate" {
  count                    = var.enable && local.launch_type == "FARGATE" ? 1 : 0
  family                   = local.family
  network_mode             = "awsvpc"
  requires_compatibilities = [local.launch_type]
  cpu                      = local.cpus
  memory                   = local.memory
  execution_role_arn       = local.exec_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = local.container_definitions
}

resource "aws_service_discovery_service" "app" {
  name = var.name

  dns_config {
    namespace_id = var.cluster["service_namespace_id"]

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # Required for private DNS namespace
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "app" {
  count           = local.enable_app ? 1 : 0
  name            = var.name
  cluster         = var.cluster["id"]
  task_definition = element(concat(aws_ecs_task_definition.ec2.*.arn, aws_ecs_task_definition.fargate.*.arn), 0)
  desired_count   = var.desired_count
  launch_type     = local.launch_type

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups = concat(local.security_groups, [aws_security_group.app[0].id])

    # List transformations to get around Terraform prohibiting:
    #   "${var.condition ? var.list1 : var.list2}"
    subnets          = split(",", var.public ? join(",", local.public_subnets) : join(",", local.private_subnets))
    assign_public_ip = var.public
  }

  service_registries {
    container_port = 0
    registry_arn   = aws_service_discovery_service.app.arn
    port           = local.lb_port
  }

  tags           = local.tags
  propagate_tags = "SERVICE"

  lifecycle {
    ignore_changes = [desired_count]
  }
}
