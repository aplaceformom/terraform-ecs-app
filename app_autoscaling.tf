resource "aws_appautoscaling_target" "alb_app" {
  count        = local.enable_alb && var.enable_autoscaling ? 1 : 0
  max_capacity = var.autoscaling_max_count
  min_capacity = var.autoscaling_min_count

  # Resource_id syntax - "service/<ecs cluster name>/<ecs service name>"
  resource_id        = "service/${var.cluster["name"]}/${aws_ecs_service.alb_app[0].name}"
  role_arn           = var.task_role_arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "alb_app" {
  count       = local.enable_alb && var.enable_autoscaling ? 1 : 0
  name        = "TargetTracking"
  policy_type = "TargetTrackingScaling"

  # Resource_id syntax - "service/<ecs cluster name>/<ecs service name>"
  resource_id        = "service/${var.cluster["name"]}/${aws_ecs_service.alb_app[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value       = var.autoscaling_target_tracking_value
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_target_tracking_metric
    }
  }

  depends_on = [aws_appautoscaling_target.alb_app]
}

resource "aws_appautoscaling_target" "ip_nlb_app" {
  count        = local.enable_ip_nlb && var.enable_autoscaling ? 1 : 0
  max_capacity = var.autoscaling_max_count
  min_capacity = var.autoscaling_min_count

  # Resource_id syntax - "service/<ecs cluster name>/<ecs service name>"
  resource_id        = "service/${var.cluster["name"]}/${aws_ecs_service.ip_nlb_app[0].name}"
  role_arn           = var.task_role_arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ip_nlb_app" {
  count       = local.enable_ip_nlb && var.enable_autoscaling ? 1 : 0
  name        = "TargetTracking"
  policy_type = "TargetTrackingScaling"

  # Resource_id syntax - "service/<ecs cluster name>/<ecs service name>"
  resource_id        = "service/${var.cluster["name"]}/${aws_ecs_service.ip_nlb_app[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_target_tracking_value

    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_target_tracking_metric
    }
  }

  depends_on = [aws_appautoscaling_target.ip_nlb_app]
}
