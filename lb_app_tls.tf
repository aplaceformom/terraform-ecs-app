/* vim: ts=2:sw=2:sts=0:expandtab */

# This is the group you need to edit if you want to restrict access to your application
# Inbound to the ALB's listeners: 80 is allowed by default and redirects to the HTTPS listener on 443. 
# The "lb_port" defaults to 443 and is allowed from any source, but can be modified.
# All outbound is allowed.
resource "aws_security_group" "lb2cluster_tls" {
  count       = local.enable_nlb_tls ? 1 : 0
  name_prefix = local.prefix
  description = "Controls access to the ALB listeners"
  vpc_id      = local.vpc_id
  tags        = local.tags
}

resource "aws_security_group_rule" "allow_service_port_tls" {
  count       = local.enable_nlb_tls ? 1 : 0
  type        = "ingress"
  protocol    = "tcp"
  from_port   = local.lb_port
  to_port     = local.lb_port
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = element(concat(aws_security_group.lb2cluster_tls.*.id, [""]), 0)
}

resource "aws_security_group_rule" "allow_80_tls" {
  count       = local.lb_port != "80" && local.enable_nlb_tls ? 1 : 0
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = element(concat(aws_security_group.lb2cluster_tls.*.id, [""]), 0)
}

resource "aws_security_group_rule" "allow_outbound_tls" {
  count       = local.enable_nlb_tls ? 1 : 0
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = element(concat(aws_security_group.lb2cluster_tls.*.id, [""]), 0)
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "cluster2app_tls" {
  count       = local.enable_nlb_tls ? 1 : 0
  name_prefix = local.prefix
  description = "Controls access to the targets behind the LB"
  vpc_id      = local.vpc_id
  tags        = local.tags

  ingress {
    protocol        = "tcp"
    from_port       = var.port
    to_port         = var.port
    security_groups = concat(local.security_groups, aws_security_group.lb2cluster_tls.*.id)
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "lb_app_tls" {
  count                = local.enable_nlb_tls ? 1 : 0
  name_prefix          = local.prefix
  port                 = var.port
  protocol             = local.tg_protocol
  vpc_id               = local.vpc_id
  target_type          = "ip"
  deregistration_delay = var.tg_dereg_delay

  health_check {
    path     = var.health_check_path
    port     = var.health_check_port
    protocol = var.health_check_protocol
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "front_end_tls" {
  count = local.enable_nlb_tls ? 1 : 0

  # Treat load-balancers as lists and perform glob expansion on each.  If the
  # load balancer isn't defined (count = 0) then it wont be expanded.  In the
  # end only 1 load balancer should be defined, we are just trying to find the
  # right one by transforming it into a list and picking element 0.
  load_balancer_arn = element(concat(aws_lb.alb.*.id, aws_lb.nlb.*.id, aws_lb.nlb_tls.*.id, aws_lb.ip_nlb.*.id), 0)

  port            = local.lb_port
  protocol        = local.lb_protocol
  ssl_policy      = local.lb_protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : ""
  certificate_arn = var.certificate

  default_action {
    target_group_arn = aws_lb_target_group.lb_app_tls[0].id
    type             = "forward"
  }
}

# Redirect port 80/tcp trafic to port 443 for HTTPS containers
resource "aws_lb_listener" "http_tls" {
  count = local.enable_nlb_tls && local.lb_protocol == "HTTPS" ? 1 : 0

  load_balancer_arn = element(concat(aws_lb.alb.*.id, aws_lb.nlb.*.id, aws_lb.nlb_tls.*.id, aws_lb.ip_nlb.*.id), 0)

  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

