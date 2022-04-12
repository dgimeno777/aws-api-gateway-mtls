data "http" "ip" {
  url = "https://ipv4.icanhazip.com/"
}

locals {
  my_public_ip            = chomp(data.http.ip.body)
  my_public_ip_cidr_block = "${local.my_public_ip}/32"
}
