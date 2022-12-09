resource "aws_ssm_parameter" "loadbalancer" {
  count     = local.enable_lb ? 1 : 0
  name      = "/scry/${var.name}/lb"
  type      = "String"
  value     = local.alarm_lb
  overwrite = true
}

resource "aws_ssm_parameter" "targetgroup" {
  count     = local.enable_lb ? 1 : 0
  name      = "/scry/${var.name}/tg"
  type      = "String"
  value     = local.alarm_tg
  overwrite = true
}

resource "aws_ssm_parameter" "service_level_settings" {
  for_each = var.service_level_settings

  name      = "/scry/${var.name}/${each.key}"
  type      = "String"
  value     = each.value
  overwrite = true
}
