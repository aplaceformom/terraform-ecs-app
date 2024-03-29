/* vim: ts=2:sw=2:sts=0:expandtab */
locals {
  enable_ip_nlb = "${local.lb_protocol == "TCP" && var.public && var.enable ? true : false}"
}

resource "aws_eip" "ip" {
  # Note: we can not reference a resource generated list (var.public_subnets)
  # as part of this code as it can not be down on the first pass.
  count = local.enable_ip_nlb ? 3 : 0
  vpc   = true
  tags  = local.tags
}

resource "aws_lb" "ip_nlb" {
  count              = local.enable_ip_nlb ? 1 : 0
  internal           = ! var.public
  name_prefix        = local.prefix
  load_balancer_type = "network"
  tags               = local.tags

  subnet_mapping {
    subnet_id     = local.public_subnets[0]
    allocation_id = aws_eip.ip[0].id
  }

  subnet_mapping {
    subnet_id     = local.public_subnets[1]
    allocation_id = aws_eip.ip[1].id
  }

  subnet_mapping {
    subnet_id     = local.public_subnets[2]
    allocation_id = aws_eip.ip[2].id
  }
}

resource "aws_ecs_service" "ip_nlb_app" {
  count           = local.enable_ip_nlb ? 1 : 0
  name            = var.name
  cluster         = var.cluster["id"]
  task_definition = element(concat(aws_ecs_task_definition.ec2.*.arn, aws_ecs_task_definition.fargate.*.arn), 0)
  desired_count   = var.desired_count
  launch_type     = local.launch_type

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

  tags           = local.tags
  propagate_tags = "SERVICE"

  depends_on = [aws_lb_listener.front_end]

  lifecycle {
    ignore_changes = [desired_count]
  }
}
