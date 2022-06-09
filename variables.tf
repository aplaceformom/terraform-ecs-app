/* vim: ts=2:sw=2:sts=0:expandtab */

variable "enable" {
  default = true
}

variable "name" {
}

variable "cluster" {
  type = map(string)
}

variable "tags" {
  type    = map
  default = {}
}

variable "cronjobs" {
  description = "A list of maps for scheduled cronjobs. Each map in the list must specify a name, command, and schedule."
  default     = []
}

variable "family" {
  default = ""
}

variable "prefix" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "exec_role_arn" {
  description = "This is required for the FARGATE launch type, optional for EC2"
  default     = ""
}

variable "create_before_destroy" {
  description = "Set the lifecycle policy of the ECS App"
  default     = ""
}

variable "region" {
  description = "Deployment region (deprecated)"
  default     = "unused"
}

variable "public" {
  default = false
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "launch_type" {
  description = "Use either FARGATE or EC2"
  default     = "FARGATE"
}

variable "cpus" {
  default = ""
}

variable "memory" {
  default = ""
}

variable "environment" {
  default = {}
}

variable "secrets" {
  default = {}
}

variable "template" {
  default = ""
}

variable "container_definitions" {
  type    = string
  default = ""
}

variable "port" {
}

variable "lb_protocol" {
  default = ""
}

variable "lb_port" {
  default = ""
}

variable "certificate" {
  description = "ARN of Certificate to use for HTTPS load balancers"
  default     = ""
}

variable "tg_dereg_delay" {
  default = 300
}

variable "tg_protocol" {
  default = ""
}

variable "container_volume_data" {
  description = "Path on container for data that gets mapped to an EFS volume. Use only with EC2 launch type"
  default     = ""
}

variable "container_volume_conf" {
  description = "Path on container for configuration that gets mapped to an EFS volume. Use only with EC2 launch type"
  default     = ""
}

variable "container_volume_logs" {
  description = "Path on container for logs that gets mapped to an EFS volume. Use only with EC2 launch type"
  default     = ""
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_port" {
  default = 80
}

variable "health_check_protocol" {
  default = "HTTP"
}

variable "health_check_unhealthy_threshold" {
  default = 2
}

variable "health_check_healthy_threshold" {
  default = 5
}

variable "health_check_timeout" {
  default = 5
}

variable "health_check_interval" {
  default = 30
}

variable "health_check_grace_period" {
  description = "Configurable attribute of the ECS service, not the target group"
  default     = 30
}

variable "health_check_success_codes" {
  default = 200
}

variable "idle_timeout" {
  description = "Idle timeout for Application load-balancers"
  default     = 60
}

variable "task_role_arn" {
  default = ""
}

variable "image" {
}

variable "desired_count" {
  default = 1
}

variable "autoscaling_target_tracking_metric" {
  default = "ECSServiceAverageCPUUtilization (deprecated)"
}

variable "autoscaling_target_tracking_value" {
  default = 65
}

variable "autoscaling_target_cpu" {
  description = "ECSServiceAverageCPUUtilization"
  default     = 50
}

variable "autoscaling_target_mem" {
  description = "ECSServiceAverageMemoryUtilization"
  default     = 50
}

variable "autoscaling_min_count" {
  default = 3
}

variable "autoscaling_max_count" {
  default = 21
}

variable "autoscaling_scale_in_cooldown" {
  default = 900
}

variable "autoscaling_scale_out_cooldown" {
  default = 60
}

variable "enable_autoscaling" {
  default = true
}

variable "enable_alarms" {
  description = "Enable CloudWatch Alarms"
  default     = true
}

variable "enable_notifications" {
  description = "Enable CloudWatch Notifications"
  default     = false
}

variable "alarm_cpu_min_percent" {
  description = "CPU under utilization alarm"
  default     = 10
}

variable "alarm_cpu_min_period" {
  description = "CPU under utilization metric period"
  default     = 900
}

variable "alarm_cpu_max_percent" {
  description = "CPU over utilization percent"
  default     = 90
}

variable "alarm_cpu_max_period" {
  description = "CPU over utilization metric period"
  default     = 900
}

variable "alarm_mem_min_percent" {
  description = "CPU under utilization percent"
  default     = 10
}

variable "alarm_mem_min_period" {
  description = "Memory under utilization metric period"
  default     = 900
}

variable "alarm_mem_max_percent" {
  description = "CPU over utilization percent"
  default     = 90
}

variable "alarm_mem_max_period" {
  description = "Memory over utilization metric period"
  default     = 900
}

variable "alarm_unhealthy_task_count" {
  description = "Alarm when some number of tasks are unhealthy"
  default     = 1
}

variable "alarm_unhealthy_task_period" {
  description = "Unhealthy task metric period"
  default     = 300
}

variable "alarm_5xx_error_percent" {
  description = "5xx error percentile alarm"
  default     = 1
}

variable "alarm_5xx_error_period" {
  description = "5xx error metric period"
  default     = 300
}

variable "enable_cloudwatch_default_alarms" {
  description = "Enables all the alarm resouces in cloudwatch.tf (deprecated)"
  default     = false
}

variable "cloudwatch_settings" {
  description = "Map of default settings for cloudwatch alarms configuration. If you want to specify custom values, copy this map and pass it to the module with your custom settings. (deprecated)"
  type        = map(string)

  default = {
    "unhealthy_hosts_threshold"    = 1
    "unhealthy_hosts_period"       = 60
    "unhealthy_hosts_eval_periods" = 3
    "unhealthy_hosts_datapoints"   = 5
    "unhealthy_hosts_statistic"    = "Maximum"
    "4XX_errors_threshold"         = 25
    "4XX_errors_period"            = 60
    "4XX_errors_statistic"         = "Sum"
    "4XX_errors_eval_periods"      = 1
    "4XX_errors_datapoints"        = 1
    "5XX_errors_threshold"         = 25
    "5XX_errors_period"            = 60
    "5XX_errors_statistic"         = "Sum"
    "5XX_errors_datapoints"        = 1
    "5XX_errors_eval_periods"      = 1
    "4XX_elb_errors_threshold"     = 25
    "4XX_elb_errors_period"        = 60
    "4XX_elb_errors_datapoints"    = 1
    "4XX_elb_errors_statistic"     = "Sum"
    "4XX_elb_errors_eval_periods"  = 1
    "5XX_elb_errors_threshold"     = 25
    "5XX_elb_errors_period"        = 60
    "5XX_elb_errors_statistic"     = "Sum"
    "5XX_elb_errors_eval_periods"  = 1
    "5XX_elb_errors_datapoints"    = 1
    "cpu_threshold"                = 75
    "cpu_period"                   = 300
    "cpu_statistic"                = "Average"
    "cpu_eval_periods"             = 2
    "cpu_datapoints"               = 2
    "memory_threshold"             = 75
    "memory_period"                = 300
    "memory_datapoints"            = 2
    "memory_eval_periods"          = 2
    "memory_statistic"             = "Average"
  }
}

variable "cloudwatch_alarm_sns_topic" {
  description = "SNS topic to configure for cloudwatch alarms to notify"
  default     = ""
}

variable "command" {
  type    = list(string)
  default = []
}

variable "elkendpoint" {
  default = ""
}

locals {
  vpc_id = "${var.vpc_id == "" ? var.cluster["vpc_id"] : var.vpc_id}"
  family = "${var.family == "" ? var.name : var.family}"
  prefix = "${var.prefix == "" ? local.family : var.prefix}"

  public_subnets  = "${split(",", length(var.public_subnets) == 0 ? var.cluster["public_subnets"] : join(",", var.public_subnets))}"
  private_subnets = "${split(",", length(var.private_subnets) == 0 ? var.cluster["private_subnets"] : join(",", var.private_subnets))}"

  security_groups = "${concat(split(",", var.cluster["security_groups"]), var.security_group_ids)}"

  port        = var.port == "" ? var.lb_port : var.port
  lb_port     = var.lb_port == "" ? var.port : var.lb_port
  lb_protocol = upper(var.lb_protocol)
  tg_protocol = var.tg_protocol == "" ? local.lb_protocol : upper(var.tg_protocol)
  launch_type = upper(var.launch_type)

  default_cpus   = local.launch_type == "FARGATE" ? "256" : "1"
  default_memory = local.launch_type == "FARGATE" ? 512 : "512"
  cpus           = var.cpus == "" ? local.default_cpus : var.cpus
  memory         = var.memory == "" ? local.default_memory : var.memory

  exec_role_arn = var.exec_role_arn == "" ? var.cluster["execution_role_arn"] : var.exec_role_arn
  elkendpoint   = var.elkendpoint == "" ? var.cluster["elk_endpoint"] : var.elkendpoint
}
