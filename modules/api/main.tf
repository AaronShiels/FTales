locals {
  origins_concatenated = join(",", var.origins)
}

resource "aws_ecr_repository" "api" {
  name = var.name
}

resource "aws_ecs_cluster" "api" {
  name = var.name
}

resource "aws_ecs_service" "api" {
  name            = "api"
  cluster         = aws_ecs_cluster.api.id
  task_definition = aws_ecs_task_definition.api.arn
  launch_type     = "FARGATE"
  desired_count   = var.scale_factor

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.api.id,
    ]

    subnets = var.private_subnet_ids
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.api.arn
  #   container_name   = "api"
  #   container_port   = "80"
  # }
}

resource "aws_security_group" "api" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "api" {
  family             = "api"
  execution_role_arn = aws_iam_role.api.arn

  container_definitions = jsonencode(
    [
      {
        name  = "api"
        image = "${aws_ecr_repository.api.repository_url}:latest"

        portMappings = [
          {
            protocol      = "tcp"
            containerPort = 80
            hostPort      = 80
          }
        ]

        environment = [
          {
            name  = "ORIGINS"
            value = local.origins_concatenated
          }
        ]

        healthCheck = {
          command = [
            "CMD-SHELL",
            "curl -f http://localhost:80/health || exit 1"
          ]
          timeout  = 5
          interval = 30
          retries  = 3
        }

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-region        = data.aws_region.current.name
            awslogs-group         = aws_cloudwatch_log_group.api.name
            awslogs-stream-prefix = "api"
          }
        }
      }
  ])

  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/api"
}

resource "aws_iam_role" "api" {
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

resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
