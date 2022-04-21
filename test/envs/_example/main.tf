data "aws_region" "current" {}

resource "random_pet" "this" {}


// build up an ipv6-enabled vpc w/ public & private nets
// i'm too lazy to do this myself
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                            = random_pet.this.id
  cidr                            = "10.0.0.0/16"
  enable_nat_gateway              = true
  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  azs = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  private_subnet_ipv6_prefixes = [0, 1]
  public_subnet_ipv6_prefixes  = [2, 3]
}
resource "aws_route53_zone" "this" {
  name = "${random_pet.this.id}.sniff.test."
}
# resource "aws_globalaccelerator_accelerator" "this" {
#   name            = "foo"
#   enabled         = true
#   ip_address_type = "IPV4"
# }

# resource "aws_lb" "this" {
#   for_each = toset(["bar", "baz"])

#   name            = each.value
#   ip_address_type = "dualstack"
# }



# resource "aws_route53_record" "target_cdn" {
#   zone_id = aws_route53_zone.this.id
#   name    = "${random_pet.this.id}-cdn.sniff.test"
#   type    = "CNAME"
#   records = ["${random_pet.this.id}.some-cdn.test."]
# }
# resource "aws_route53_record" "target_aga_v4" {
#   zone_id = aws_route53_zone.this.id
# }

# resource "aws_route53_record" "target_lat_v6" {
#   zone_id = aws_route53_zone.this.id
# }

output "zone" {
  value = aws_route53_zone.this
}

output "vpc" {
  value = module.vpc
}

# output "aga" {
#   value = aws_globalaccelerator_accelerator.this
# }

# output "lb" {
#   value = aws_lb.this
# }
