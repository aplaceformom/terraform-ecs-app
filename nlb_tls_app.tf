/* vim: ts=2:sw=2:sts=0:expandtab */

resource "aws_lb" "nlb_tls" {
  count              = local.enable_nlb_tls ? 1 : 0
  name_prefix        = local.prefix
  load_balancer_type = "network"
  internal           = true
  tags               = local.tags
  subnets            = local.private_subnets
}

resource "aws_ecs_service" "nlb_tls_app" {
  count           = local.enable_nlb_tls ? 1 : 0
  name            = var.name
  cluster         = var.cluster["id"]
  tags            = local.tags
  task_definition = element(concat(aws_ecs_task_definition.ec2.*.arn, aws_ecs_task_definition.fargate.*.arn), 0)
  desired_count   = var.desired_count
  launch_type     = local.launch_type

  health_check_grace_period_seconds = var.health_check_grace_period

  network_configuration {
    subnets         = local.private_subnets
    security_groups = concat(local.security_groups, [aws_security_group.lb2cluster_tls[0].id])
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_app_tls[0].id
    container_name   = var.name
    container_port   = var.port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app.arn
    port         = local.port
  }

  depends_on = [aws_lb_listener.front_end_tls]
}

