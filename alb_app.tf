/* vim: ts=2:sw=2:sts=0:expandtab */

resource "aws_lb" "alb" {
  count              = local.enable_alb ? 1 : 0
  name_prefix        = local.prefix
  load_balancer_type = "application"
  internal           = var.public ? false : true
  subnets = split(
    ",",
    var.public ? join(",", local.public_subnets) : join(",", local.private_subnets),
  )
  idle_timeout = var.idle_timeout

  security_groups = [aws_security_group.lb2cluster[0].id]

  tags = local.tags
}

resource "aws_ecs_service" "alb_app" {
  count   = local.enable_alb ? 1 : 0
  name    = var.name
  cluster = var.cluster["id"]
  task_definition = element(
    concat(
      aws_ecs_task_definition.ec2.*.arn,
      aws_ecs_task_definition.fargate.*.arn,
    ),
    0,
  )
  desired_count = var.desired_count
  launch_type   = local.launch_type

  health_check_grace_period_seconds = var.health_check_grace_period

  network_configuration {
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    security_groups = concat(local.security_groups, [aws_security_group.cluster2app[0].id])
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    subnets = local.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_app[0].id
    container_name   = var.name
    container_port   = var.port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app.arn
    port         = var.port
  }

  depends_on = [aws_lb_listener.front_end]

  tags = local.tags
}

