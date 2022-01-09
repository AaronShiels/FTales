resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  launch_type     = "FARGATE"
  desired_count   = var.scale_factor

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.service.id,
    ]

    subnets = var.subnet_ids
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.service.arn
  #   container_name   = "api"
  #   container_port   = "80"
  # }
}

resource "aws_security_group" "service" {
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.service.id
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.port_mapping

  type              = "ingress"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.service.id
}

resource "aws_ecs_task_definition" "service" {
  family             = var.name
  execution_role_arn = aws_iam_role.service.arn

  container_definitions = jsonencode(
    [
      {
        name  = var.name
        image = var.image

        portMappings = [for k, v in var.port_mapping : {
          protocol      = "tcp"
          hostPort      = tonumber(k)
          containerPort = tonumber(v)
        }]

        environment = [for k, v in var.environment : {
          name  = k
          value = v
        }]

        healthCheck = {
          command = [
            "CMD-SHELL",
            "curl -f ${var.health_check_url} || exit 1"
          ]
          timeout  = 5
          interval = 30
          retries  = 3
        }

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-region        = data.aws_region.current.name
            awslogs-group         = aws_cloudwatch_log_group.service.name
            awslogs-stream-prefix = var.name
          }
        }
      }
  ])

  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_cloudwatch_log_group" "service" {
  name = "/ecs/${var.name}"
}

resource "aws_iam_role" "service" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "1",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
