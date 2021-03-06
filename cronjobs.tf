locals {
  overrides = {}
}

resource "aws_cloudwatch_event_rule" "cronjobs" {
  count               = length(var.cronjobs)
  name                = var.cronjobs[count.index]["name"]
  schedule_expression = "cron(${var.cronjobs[count.index]["schedule"]})"
}

resource "aws_cloudwatch_event_target" "cronjobs" {
  count     = length(var.cronjobs)
  target_id = var.cronjobs[count.index]["name"]
  arn       = var.cluster["id"]
  rule      = element(aws_cloudwatch_event_rule.cronjobs.*.name, count.index)
  role_arn  = element(aws_iam_role.cronjobs.*.arn, count.index)

  ecs_target {
    task_count          = 1
    task_definition_arn = element(concat(aws_ecs_service.alb_app.*.task_definition, aws_ecs_service.app.*.task_definition, aws_ecs_service.ip_nlb_app.*.task_definition, aws_ecs_service.nlb_app.*.task_definition, list("")), 0)

    launch_type = var.launch_type
    network_configuration {
      subnets = local.private_subnets
    }
  }

  input = <<EOF
{
  "containerOverrides": [
    {
      "name":    "${var.name}",
      "command": "${lookup(var.cronjobs[count.index], "command")}"
    }
  ]
}
EOF
}

# These are defaults from terraform's documentation - they are required for
# cloudwatch to be able to trigger ecs tasks.
resource "aws_iam_role" "cronjobs" {
  count = length(var.cronjobs) > 0 ? 1 : 0
  name  = "ecs_schedule_${var.name}"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "cronjobs" {
  count = length(var.cronjobs) > 0 ? 1 : 0
  name  = "${var.name}_cronjobs"
  role  = element(concat(aws_iam_role.cronjobs.*.name, list("")), 0)

  # This allows the cloudwatch rule to pass the default execution role to ECS
  # to launch the task with.  The policy does not support the wildcard
  # resource, you must give a specific role arn. The replace() syntax will
  # wildcard the versions for the task definition.
  policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "iam:ListInstanceProfiles",
              "iam:ListRoles",
              "iam:PassRole"
          ],
          "Resource": "*"
      }, {
          "Effect": "Allow",
          "Action": "ecs:RunTask",
          "Resource": "${replace(element(concat(aws_ecs_service.alb_app.*.task_definition, aws_ecs_service.app.*.task_definition, aws_ecs_service.ip_nlb_app.*.task_definition, aws_ecs_service.nlb_app.*.task_definition, [""]), 0), "/:\\d+$/", ":*")}"
      }
  ]
}
DOC
}
