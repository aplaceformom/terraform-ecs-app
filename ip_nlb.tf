/* vim: ts=2:sw=2:sts=0:expandtab */

resource "aws_eip" "ip" {
  # Note: we can not reference a resource generated list (var.public_subnets)
  # as part of this code as it can not be down on the first pass.
  count = local.enable_ip_nlb ? 3 : 0

  vpc = true
}

resource "aws_lb" "ip_nlb" {
  count              = local.enable_ip_nlb ? 1 : 0
  name_prefix        = local.prefix
  load_balancer_type = "network"

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
  count   = local.enable_ip_nlb ? 1 : 0
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
    subnets = local.private_subnets
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    security_groups = concat(local.security_groups, [aws_security_group.lb2cluster[0].id])
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_app[0].id
    container_name   = var.name
    container_port   = var.port
  }

  depends_on = [aws_lb_listener.front_end]
}

