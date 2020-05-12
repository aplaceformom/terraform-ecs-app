/* vim: ts=2:sw=2:sts=0:expandtab */

data "template_file" "ec2" {
  count    = local.launch_type == "EC2" ? 1 : 0
  template = local.template

  vars = {
    name                = var.name
    image               = var.image
    nlb_public_ips      = local.enable_ip_nlb ? join(" ", aws_eip.ip.*.public_ip) : ""
    nlb_private_ips     = local.enable_ip_nlb ? join(" ", aws_eip.ip.*.private_ip) : ""
    command             = jsonencode(var.command)
    cpu                 = local.cpus
    memory              = local.memory
    port                = var.port
    region              = local.region
    family              = local.family
    prefix              = local.prefix
    environment         = terraform.workspace
    source_volume_data  = "${var.name}-data"
    source_volume_conf  = "${var.name}-conf"
    source_volume_logs  = "${var.name}-logs"
    container_path_data = var.container_volume_data
    container_path_conf = var.container_volume_conf
    container_path_logs = var.container_volume_logs
  }
}

data "template_file" "fargate" {
  count    = local.launch_type == "FARGATE" ? 1 : 0
  template = local.template

  vars = {
    name            = var.name
    image           = var.image
    nlb_public_ips  = local.enable_ip_nlb ? join(" ", aws_eip.ip.*.public_ip) : ""
    nlb_private_ips = local.enable_ip_nlb ? join(" ", aws_eip.ip.*.private_ip) : ""
    command         = jsonencode(var.command)
    cpu             = local.cpus
    memory          = local.memory
    port            = var.port
    region          = local.region
    family          = local.family
    prefix          = local.prefix
    environment     = terraform.workspace
  }
}

