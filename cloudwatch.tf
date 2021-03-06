locals {
  alarm_lb = element(concat(aws_lb.alb.*.arn_suffix, aws_lb.nlb.*.arn_suffix, aws_lb.ip_nlb.*.arn_suffix, [""]), 0)
  alarm_tg = element(concat(aws_lb_target_group.lb_app.*.arn_suffix, [""]), 0)
}

resource "aws_sns_topic" "alarms" {
  count = var.enable_alarms && var.enable ? 1 : 0
  name  = "${var.name}_alarms"
}

resource "aws_sns_topic" "info" {
  count = var.enable_notifications && var.enable ? 1 : 0
  name  = "${var.name}_info"
}

resource "aws_cloudwatch_metric_alarm" "deployment" {
  count              = var.enable_notifications && var.enable ? 1 : 0
  alarm_name         = "${var.name}_deployment"
  alarm_description  = "Deployment in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.info[0].arn]
  ok_actions         = [aws_sns_topic.info[0].arn]
  evaluation_periods = 2

  namespace           = "ECS/ContainerInsights"
  metric_name         = "DeploymentCount"
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  threshold           = 1
  period              = 60

  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = var.name
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "pending" {
  count              = var.enable_alarms && var.enable ? 1 : 0
  alarm_name         = "${var.name}_pending"
  alarm_description  = "Pending deployment in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]
  ok_actions         = [aws_sns_topic.alarms[0].arn]
  evaluation_periods = 2
  treat_missing_data = "notBreaching"

  namespace           = "ECS/ContainerInsights"
  metric_name         = "DeploymentCount"
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  threshold           = 1
  period              = 900

  dimensions = {
    ClusterName = "${var.cluster["name"]}"
    ServiceName = "${var.name}"
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_tasks" {
  count              = var.enable_alarms && local.enable_lb && var.enable ? 1 : 0
  alarm_name         = "${var.name}_unhealthy_tasks"
  alarm_description  = "ECS task health in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]
  ok_actions         = [aws_sns_topic.alarms[0].arn]
  evaluation_periods = 2
  treat_missing_data = "notBreaching"

  namespace           = local.enable_nlb ? "AWS/NetworkELB" : local.enable_lb ? "AWS/ApplicationELB" : ""
  metric_name         = "UnHealthyHostCount"
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  threshold           = var.alarm_unhealthy_task_count
  period              = var.alarm_unhealthy_task_period

  dimensions = {
    LoadBalancer = local.alarm_lb
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "errors_5xx" {
  count              = var.enable_alarms && local.enable_alb && var.enable ? 1 : 0
  alarm_name         = "${var.name}_5xx_errors"
  alarm_description  = "5xx error rate in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]
  ok_actions         = [aws_sns_topic.alarms[0].arn]
  evaluation_periods = 2
  treat_missing_data = "notBreaching"

  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  comparison_operator = "GreaterThanThreshold"
  extended_statistic  = "p100"
  threshold           = var.alarm_5xx_error_percent
  period              = var.alarm_5xx_error_period

  dimensions = {
    LoadBalancer = local.alarm_lb
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_max" {
  count              = var.enable_alarms && var.enable ? 1 : 0
  alarm_name         = "${var.name}_cpu_max"
  alarm_description  = "Max CPU usage in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]
  ok_actions         = [aws_sns_topic.alarms[0].arn]
  evaluation_periods = 2

  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  threshold           = var.alarm_cpu_max_percent
  period              = var.alarm_cpu_max_period

  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = var.name
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_min" {
  count              = var.enable_notifications && var.enable ? 1 : 0
  alarm_name         = "${var.name}_cpu_min"
  alarm_description  = "Min CPU usage in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.info[0].arn]
  ok_actions         = [aws_sns_topic.info[0].arn]
  evaluation_periods = 2

  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  comparison_operator = "LessThanThreshold"
  statistic           = "Average"
  threshold           = var.alarm_cpu_min_percent
  period              = var.alarm_cpu_min_period

  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = var.name
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "mem_max" {
  count              = var.enable_alarms && var.enable ? 1 : 0
  alarm_name         = "${var.name}_mem_max"
  alarm_description  = "Max memory usage in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.alarms[0].arn]
  ok_actions         = [aws_sns_topic.alarms[0].arn]
  evaluation_periods = 2

  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  threshold           = var.alarm_mem_max_percent
  period              = var.alarm_mem_max_period

  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = var.name
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "mem_min" {
  count              = var.enable_notifications && var.enable ? 1 : 0
  alarm_name         = "${var.name}_mem_min"
  alarm_description  = "Min memory usage in ${terraform.workspace}"
  alarm_actions      = [aws_sns_topic.info[0].arn]
  ok_actions         = [aws_sns_topic.info[0].arn]
  evaluation_periods = 2

  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  comparison_operator = "LessThanThreshold"
  statistic           = "Average"
  threshold           = var.alarm_mem_min_percent
  period              = var.alarm_mem_min_period

  dimensions = {
    ClusterName = var.cluster["name"]
    ServiceName = var.name
  }

  tags = local.tags
}
