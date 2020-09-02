/* vim: ts=2:sw=2:sts=0:expandtab */

variable "enable" {
  default = true
}

variable "name" {
}

variable "cluster" {
  type = map(string)
}

variable "cronjobs" {
  description = "A list of maps for scheduled cronjobs. Each map in the list must specify a name, command, and schedule."
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to created resources"
  default     = {}
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

variable "region" {
  description = "Deployment region (deprecated)"
  default = "unused"
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

variable "mount_points" {
  description = "Key=Value mappings of mount points"
  default     = {}
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
  default = 50
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
  default = 30
}

variable "autoscaling_scale_in_cooldown" {
  default = 300
}

variable "autoscaling_scale_out_cooldown" {
  default = 300
}

variable "enable_autoscaling" {
  default = false
}

variable "enable_cloudwatch_default_alarms" {
  description = "Enables all the alarm resouces in cloudwatch.tf"
  default     = false
}

variable "cloudwatch_settings" {
  description = "Map of default settings for cloudwatch alarms configuration. If you want to specify custom values, copy this map and pass it to the module with your custom settings."
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
  vpc_id = var.vpc_id == "" ? var.cluster["vpc_id"] : var.vpc_id
  family = var.family == "" ? var.name : var.family
  prefix = var.prefix == "" ? local.family : var.prefix

  public_subnets  = split(",", length(var.public_subnets) == 0 ? var.cluster["public_subnets"] : join(",", var.public_subnets))
  private_subnets = split(",", length(var.private_subnets) == 0 ? var.cluster["private_subnets"] : join(",", var.private_subnets))

  security_groups = concat(split(",", var.cluster["security_groups"]), var.security_group_ids)

  port        = var.port == "" ? var.lb_port : var.port
  lb_port     = var.lb_port == "" ? var.port : var.lb_port
  lb_protocol = upper(var.lb_protocol)
  tg_protocol = var.tg_protocol == "" ? local.lb_protocol : upper(var.tg_protocol)
  enable_app  = local.lb_protocol == "" && var.enable ? true : false

  #do not use lb_app if the protocol is TLS, as the healthchecks won't work
  enable_lb  = local.lb_protocol != "" && local.lb_protocol != "TLS" && var.enable ? true : false
  enable_alb = local.lb_protocol != "TCP" && local.enable_lb ? true : false

  #will use enable_nlb_tls variable to deal with the TLS protocol
  enable_nlb_tls = local.lb_protocol == "TLS" && false == var.public && var.enable ? true : false
  enable_nlb     = local.lb_protocol == "TCP" && false == var.public && var.enable ? true : false
  enable_ip_nlb  = local.lb_protocol == "TCP" && var.public && var.enable ? true : false
  launch_type    = upper(var.launch_type)

  default_cpus   = local.launch_type == "FARGATE" ? "256" : "1"
  default_memory = local.launch_type == "FARGATE" ? 512 : "512"
  cpus           = var.cpus == "" ? local.default_cpus : var.cpus
  memory         = var.memory == "" ? local.default_memory : var.memory

  exec_role_arn = var.exec_role_arn == "" ? var.cluster["execution_role_arn"] : var.exec_role_arn
  elkendpoint   = var.elkendpoint == "" ? var.cluster["elk_endpoint"] : var.elkendpoint
}

