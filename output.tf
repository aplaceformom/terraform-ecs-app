output "output" {
  value = {
    "name" = var.name
    "port" = var.port
    "arn" = element(
      concat(
        aws_ecs_service.alb_app.*.task_definition,
        aws_ecs_service.app.*.task_definition,
        aws_ecs_service.ip_nlb_app.*.task_definition,
        aws_ecs_service.nlb_tls_app.*.task_definition,
        aws_ecs_service.nlb_app.*.task_definition,
        [""],
      ),
      0,
    )
  }
}

output "lb" {
  value = {
    "port"     = var.port
    "protocol" = local.lb_protocol
    "dnsname" = element(
      concat(
        aws_lb.alb.*.dns_name,
        aws_lb.nlb.*.dns_name,
        aws_lb.nlb_tls.*.dns_name,
        aws_lb.ip_nlb.*.dns_name,
        [""],
      ),
      0,
    )
    "ecs_service_name" = element(
      concat(
        aws_ecs_service.alb_app.*.name,
        aws_ecs_service.app.*.name,
        aws_ecs_service.nlb_tls_app.*.name,
        aws_ecs_service.ip_nlb_app.*.name,
        aws_ecs_service.nlb_app.*.name,
        [""],
      ),
      0,
    )
    "endpoint" = "${lower(local.lb_protocol)}://${element(
      concat(
        aws_lb.alb.*.dns_name,
        aws_lb.nlb.*.dns_name,
        aws_lb.nlb_tls.*.dns_name,
        aws_lb.ip_nlb.*.dns_name,
        [""],
      ),
      0,
    )}:${local.lb_port}"
    "zone_id" = element(
      concat(
        aws_lb.alb.*.zone_id,
        aws_lb.nlb_tls.*.zone_id,
        aws_lb.nlb.*.zone_id,
        aws_lb.ip_nlb.*.zone_id,
        [""],
      ),
      0,
    )
    "elb_arn" = element(
      concat(
        aws_lb.alb.*.arn,
        aws_lb.nlb_tls.*.arn,
        aws_lb.nlb.*.arn,
        aws_lb.ip_nlb.*.arn,
        [""],
      ),
      0,
    )
    "elb_arn_suffix" = element(
      concat(
        aws_lb.alb.*.arn_suffix,
        aws_lb.nlb_tls.*.arn_suffix,
        aws_lb.nlb.*.arn_suffix,
        aws_lb.ip_nlb.*.arn_suffix,
        [""],
      ),
      0,
    )
    "tg_arn" = element(
      concat(
        aws_lb_target_group.lb_app.*.arn,
        aws_lb_target_group.lb_app_tls.*.arn,
        [""],
      ),
      0,
    )
    "tg_arn_suffix" = element(
      concat(
        aws_lb_target_group.lb_app.*.arn_suffix,
        aws_lb_target_group.lb_app_tls.*.arn_suffix,
        [""],
      ),
      0,
    )
    "https_listener_arn" = element(
      concat(
        aws_lb_listener.front_end.*.arn,
        aws_lb_listener.front_end_tls.*.arn,
        [""],
      ),
      0,
    )
    "http_listener_arn" = element(
      concat(
        aws_lb_listener.http.*.arn,
        aws_lb_listener.http_tls.*.arn,
        [""],
      ),
      0,
    )
    "lb_sg_id" = element(
      concat(
        aws_security_group.lb2cluster.*.id,
        aws_security_group.lb2cluster_tls.*.id,
        [""],
      ),
      0,
    )
    "target_sg_id" = element(
      concat(
        aws_security_group.cluster2app.*.id,
        aws_security_group.cluster2app_tls.*.id,
        [""],
      ),
      0,
    )
  }
}

