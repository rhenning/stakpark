data "aws_region" "current" {}

resource "random_pet" "this" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                            = random_pet.this.id
  cidr                            = "10.0.0.0/16"
  enable_nat_gateway              = true
  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  azs = ["${data.aws_region.current.name}a"]

  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  private_subnet_ipv6_prefixes = [0]
  public_subnet_ipv6_prefixes  = [1]
}
resource "aws_route53_zone" "this" {
  name = "${random_pet.this.id}.sniff.test."
}

resource "aws_route53_record" "target_cdn" {
  zone_id = aws_route53_zone.this.id
  name    = "${random_pet.this.id}-cdn.${aws_route53_zone.this.name}"
  type    = "CNAME"
  ttl     = 30
  records = ["${random_pet.this.id}.some-cdn.test."]
}

resource "aws_route53_record" "target_aga_v4" {
  zone_id = aws_route53_zone.this.id
  name    = "${random_pet.this.id}-ds.${aws_route53_zone.this.name}"
  type    = "A"
  ttl     = 30
  records = ["127.0.0.1"]
}

resource "aws_route53_record" "target_lat_v6_use1" {
  zone_id        = aws_route53_zone.this.id
  name           = "${random_pet.this.id}-ds.${aws_route53_zone.this.name}"
  type           = "AAAA"
  ttl            = 30
  records        = ["fe80:1:feed:beef"]
  set_identifier = "use1"

  latency_routing_policy {
    region = "us-east-1"
  }
}

resource "aws_route53_record" "target_lat_v6_usw2" {
  zone_id        = aws_route53_zone.this.id
  name           = "${random_pet.this.id}-ds.${aws_route53_zone.this.name}"
  type           = "AAAA"
  ttl            = 30
  records        = ["fe80:1:dead:beef"]
  set_identifier = "usw2"

  latency_routing_policy {
    region = "us-west-2"
  }
}

resource "aws_route53_record" "weighted_edge_cdn" {
  zone_id        = aws_route53_zone.this.id
  name           = "${random_pet.this.id}.${aws_route53_zone.this.name}"
  type           = "CNAME"
  ttl            = 30
  records        = [aws_route53_record.target_cdn.name]
  set_identifier = "cdn"

  weighted_routing_policy {
    weight = 1
  }
}

resource "aws_route53_record" "weighted_edge_origin" {
  zone_id        = aws_route53_zone.this.id
  name           = "${random_pet.this.id}.${aws_route53_zone.this.name}"
  type           = "CNAME"
  ttl            = 30
  records        = [aws_route53_record.target_cdn.name]
  set_identifier = "origin"

  weighted_routing_policy {
    weight = 3
  }
}

output "zone" {
  value = aws_route53_zone.this
}

output "vpc" {
  value = module.vpc
}
