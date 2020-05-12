resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count               = var.enable_cloudwatch_default_alarms ? 1 : 0
  alarm_name          = "${var.name}_unhealthy_hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_settings["unhealthy_hosts_eval_periods"]
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_settings["unhealthy_hosts_period"]
  statistic           = var.cloudwatch_settings["unhealthy_hosts_statistic"]
  threshold           = var.cloudwatch_settings["unhealthy_hosts_threshold"]
  datapoints_to_alarm = var.cloudwatch_settings["unhealthy_hosts_datapoints"]
  alarm_description   = "Alarms if unhealthy hosts in the target group exceed threshold"
  alarm_actions       = [var.cloudwatch_alarm_sns_topic]
  dimensions = {
    LoadBalancer = element(
      concat(
        aws_lb.alb.*.arn_suffix,
        aws_lb.nlb.*.arn_suffix,
        aws_lb.nlb_tls.*.arn_suffix,
        aws_lb.ip_nlb.*.arn_suffix,
        [""],
      ),
      0,
    )
    TargetGroup = element(
      concat(
        aws_lb_target_group.lb_app.*.arn_suffix,
        aws_lb_target_group.lb_app_tls.*.arn_suffix,
        [""],
      ),
      0,
    )
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.enable_cloudwatch_default_alarms ? 1 : 0
  alarm_name          = "${var.name}_cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_settings["cpu_eval_periods"]
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_settings["cpu_period"]
  statistic           = var.cloudwatch_settings["cpu_statistic"]
  threshold           = var.cloudwatch_settings["cpu_threshold"]
  datapoints_to_alarm = var.cloudwatch_settings["cpu_datapoints"]
  alarm_description   = "Alarms if ECS service CPU utilization exceed threshold"
  alarm_actions       = [var.cloudwatch_alarm_sns_topic]
  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = element(
      concat(
        aws_ecs_service.alb_app.*.name,
        aws_ecs_service.app.*.name,
        aws_ecs_service.ip_nlb_app.*.name,
        aws_ecs_service.nlb_tls_app.*.name,
        aws_ecs_service.nlb_app.*.name,
        [""],
      ),
      0,
    )
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  count               = var.enable_cloudwatch_default_alarms ? 1 : 0
  alarm_name          = "${var.name}_memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_settings["memory_eval_periods"]
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_settings["memory_period"]
  statistic           = var.cloudwatch_settings["memory_statistic"]
  threshold           = var.cloudwatch_settings["memory_threshold"]
  datapoints_to_alarm = var.cloudwatch_settings["memory_datapoints"]
  alarm_description   = "Alarms if ECS service memory utilization exceed threshold"
  alarm_actions       = [var.cloudwatch_alarm_sns_topic]
  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = element(
      concat(
        aws_ecs_service.alb_app.*.name,
        aws_ecs_service.app.*.name,
        aws_ecs_service.ip_nlb_app.*.name,
        aws_ecs_service.nlb_tls_app.*.name,
        aws_ecs_service.nlb_app.*.name,
        [""],
      ),
      0,
    )
  }
}

# Create log group for lambda subscription
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = var.name
  retention_in_days = 14
}

