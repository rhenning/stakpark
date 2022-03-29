resource "random_pet" "this" {}

// let's create a new VPC to associate with a private hosted zone for our demo
resource "aws_vpc" "pet" {
  cidr_block = "192.168.13.0/24"

  tags = {
    Name = random_pet.this.id
  }
}

resource "aws_route53_zone" "phz" {
  name = "${aws_vpc.pet.tags["Name"]}.sniff.test"

  vpc {
    vpc_id = aws_vpc.pet.id
  }

  // ignore changes to the inline `vpc` attachments so that future executions of `terraform apply`
  // don't undo the standalone or externally-managed `aws_route53_zone_association` resources.
  // see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association#example-usage
  lifecycle {
    ignore_changes = [vpc]
  }

  // this feels a little hacky b/c it's something of a workaround. AWS actually _requires_ a VPC
  // attribute at create time in order to declare a zone "private", so we give the API what it
  // wants, by setting it initially when creating the zone, but then use a `lifecycle` block to
  // hint at Terraform to leave the inline vpc{} field on the resource alone when evaluating the
  // CRUD graph, and let the standalone "additive" `aws_route53_zone_association` resource(s)
  // manage any desired association(s) instead.
}

// now declare a standalone attachment used to surgically manage the zone
// associations r
# resource "aws_route53_zone_association" "pet" {
#   zone_id = aws_route53_zone.phz.zone_id
#   vpc_id  = aws_vpc.pet.id
# }

// just for demonstration's sake, let's also select and associate the default
// vpc. try uncommenting, running apply, then recommenting, and running apply.
// notice that the standalone resource is smart enough to only mess with VPCs
// that match its select criteria, unlike aws_vpc's inline vpc{} blocks, which
// are absolute.
# data "aws_vpc" "default" {
#   default = true
# }

# resource "aws_route53_zone_association" "default" {
#   zone_id = aws_route53_zone.phz.zone_id
#   vpc_id  = data.aws_vpc.default.id
# }

output "vpc" {
  value = aws_vpc.pet
}

output "zone" {
  value = aws_route53_zone.phz
}
