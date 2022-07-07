resource "aws_ssm_parameter" "loadbalancer" {
  name  = "/scry/${var.name}/lb"
  type  = "String"
  value = local.alarm_lb
}

resource "aws_ssm_parameter" "targetgroup" {
  name  = "/scry/${var.name}/tg"
  type  = "String"
  value = local.alarm_tg
}

resource "aws_ssm_parameter" "service_level_settings" {
  for_each = var.service_level_settings

  name  = "/scry/${var.name}/${each.key}"
  type  = "String"
  value = each.value
}
