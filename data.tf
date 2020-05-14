/* vim: ts=2:sw=2:sts=0:expandtab */
locals {
  environs = merge(var.environment, { environment = terraform.workspace })
  environ = [
   for key in keys(local.environs): {
     name = key
     value = local.environs[key]
   }
  ]

  mount_points = [
   for key in keys(var.mount_points): {
     sourceVolume = key
     containerPath = var.mount_points[key]
     readOnly = false
   }
  ]

  template = [{
    name   = var.name
    image  = var.image
    cpu    = var.cpus
    memory = var.memory
    command = var.command
    essential = true
    portMappings = [{
      hostPort = var.port
      containerPort = var.port
      protocol = "tcp"
    }]
    mountPoints = local.mount_points
    environment = local.environ
    logConfiguration = {
      logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-region = var.region
          awslogs-group = var.family
          awslogs-stream-prefix = var.prefix
        }
     }
  }]
}
