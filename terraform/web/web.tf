resource "aws_ecs_cluster" "web" {
  name = "${local.resource_name_prefix}-${local.resource_name_suffix}"
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.web.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${local.resource_name_prefix}-${local.resource_name_suffix}"
  execution_role_arn       = aws_iam_role.web_service_execution.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "mtls-web"
      image     = local.web_image_uri
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "web" {
  name            = "${local.resource_name_prefix}-${local.resource_name_suffix}"
  cluster         = aws_ecs_cluster.web.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      data.aws_subnet.web.id
    ]
    security_groups = [
      aws_security_group.web.id
    ]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.mtls_gateway.arn
    container_name   = aws_ecs_task_definition.web.family
    container_port   = 80
  }
}

resource "aws_security_group" "web" {
  name   = "${local.resource_name_prefix}-web-${local.resource_name_suffix}"
  vpc_id = data.aws_vpc.web.id
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_iam_role" "web_service_execution" {
  name = "${local.resource_name_prefix}-service-execution-${local.resource_name_suffix}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        "Action" : "sts:AssumeRole"
        "Effect" : "Allow"
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "web_service_execution" {
  role       = aws_iam_role.web_service_execution.name
  policy_arn = aws_iam_policy.web_service_execution.arn
}

resource "aws_iam_policy" "web_service_execution" {
  name = "${local.resource_name_prefix}-service-execution-${local.resource_name_suffix}"
  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}
