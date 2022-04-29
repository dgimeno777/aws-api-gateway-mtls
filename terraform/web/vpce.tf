locals {
  vpce_interface_services = [
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "ecr.dkr",
    "ecr.api",
  ]
}

data "aws_vpc_endpoint_service" "interface_services" {
  for_each     = toset(local.vpce_interface_services)
  service      = each.key
  service_type = "Interface"
}

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

resource "aws_vpc_endpoint" "interface_services" {
  for_each            = data.aws_vpc_endpoint_service.interface_services
  vpc_id              = data.aws_vpc.web.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    data.aws_subnet.web.id
  ]
  security_group_ids = [
    aws_security_group.vpce.id
  ]
}

resource "aws_vpc_endpoint" "s3" {
  service_name        = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type   = "Gateway"
  vpc_id              = data.aws_vpc.web.id
  private_dns_enabled = false
  route_table_ids = [
    data.aws_route_table.web.id
  ]
}
