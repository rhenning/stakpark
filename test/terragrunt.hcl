## this file contains terragrunt configuration that is common to all environments.
## for invividual environment overrides, please see envs/<name>/terragrunt.hcl.

locals {
  terraform_version   = "1.1.7"
  aws_region          = "us-east-1"
  localstack_endpoint = "http://localhost:4566"

  localstack_services = [
    "acm",
    "ec2",
    "route53",
    "s3",
    "sts",
  ]
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"

  contents = templatefile("providers.tf.tmpl", {
    aws_region = local.aws_region

    localstack_services = local.localstack_services
    localstack_endpoint = local.localstack_endpoint
  })
}

#generate "terraform_version" {
#  path      = ".terraform-version"
#  if_exists = "overwrite_terragrunt"
#
#  contents = <<EOF
#${local.terraform_version}
#EOF
#}
