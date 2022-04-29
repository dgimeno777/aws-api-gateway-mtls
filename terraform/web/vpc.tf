data "aws_subnet" "web" {
  id = var.web_subnet_id
}

data "aws_route_table" "web" {
  subnet_id = data.aws_subnet.web.id
}

data "aws_vpc" "web" {
  id = data.aws_subnet.web.vpc_id
}
