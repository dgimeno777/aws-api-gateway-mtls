resource "aws_security_group" "vpce" {
  name   = "${local.resource_name_prefix}-vpce-${local.resource_name_suffix}"
  vpc_id = data.aws_vpc.web.id
  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = [
      data.aws_subnet.web.cidr_block
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

resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = data.aws_vpc.web.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    data.aws_subnet.web.id
  ]
  security_group_ids = [
    aws_security_group.vpce.id
  ]
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = data.aws_vpc.web.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    data.aws_subnet.web.id
  ]
  security_group_ids = [
    aws_security_group.vpce.id
  ]
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id              = data.aws_vpc.web.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    data.aws_subnet.web.id
  ]
  security_group_ids = [
    aws_security_group.vpce.id
  ]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.aws_vpc.web.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    data.aws_subnet.web.id
  ]
  security_group_ids = [
    aws_security_group.vpce.id
  ]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.aws_vpc.web.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    data.aws_subnet.web.id
  ]
  security_group_ids = [
    aws_security_group.vpce.id
  ]
}
