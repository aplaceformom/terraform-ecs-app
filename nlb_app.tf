/* vim: ts=2:sw=2:sts=0:expandtab */
locals {
  enable_nlb = "${(local.lb_protocol == "TCP" || local.lb_protocol == "TLS") && ! var.public && var.enable ? true : false}"
}

resource "aws_lb" "nlb" {
  count              = local.enable_nlb ? 1 : 0
  name_prefix        = local.prefix
  load_balancer_type = "network"
  internal           = var.public ? false : true
  subnets            = local.private_subnets
  tags               = local.tags
}

resource "aws_ecs_service" "nlb_app" {
  count           = local.enable_nlb ? 1 : 0
  name            = var.name
  cluster         = var.cluster["id"]
  task_definition = element(concat(aws_ecs_task_definition.ec2.*.arn, aws_ecs_task_definition.fargate.*.arn), 0)
  desired_count   = var.desired_count
  launch_type     = local.launch_type
  tags            = local.tags
  propagate_tags  = "SERVICE"

  health_check_grace_period_seconds = var.health_check_grace_period

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets         = local.private_subnets
    security_groups = concat(local.security_groups, [aws_security_group.lb2cluster[0].id])
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_app[0].id
    container_name   = var.name
    container_port   = var.port
  }

  service_registries {
    container_port = 0
    registry_arn   = aws_service_discovery_service.app.arn
    port           = local.lb_port
  }

  depends_on = [aws_lb_listener.front_end]

  lifecycle {
    ignore_changes = [desired_count]
  }
}
