resource "aws_ssm_parameter" "loadbalancer" {
  count = local.enable_lb && var.enable && var.enable_service_level_monitoring ? 1 : 0
  name  = "/${terraform.workspace}/scry/${var.name}/lb"
  type  = "String"
  value = local.alarm_lb
}

resource "aws_ssm_parameter" "targetgroup" {
  count = local.enable_lb && var.enable && var.enable_service_level_monitoring ? 1 : 0
  name  = "/${terraform.workspace}/scry/${var.name}/tg"
  type  = "String"
  value = local.alarm_tg
}

resource "aws_ssm_parameter" "service_level_settings" {
  for_each = var.service_level_settings

  name  = "/${terraform.workspace}/scry/${var.name}/${each.key}"
  type  = "String"
  value = each.value
}