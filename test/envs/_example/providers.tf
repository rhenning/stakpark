# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "aws" {
  region = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  s3_use_path_style = true

  endpoints {
        acm = "http://localhost:4566"
        ec2 = "http://localhost:4566"
        route53 = "http://localhost:4566"
        s3 = "http://localhost:4566"
        sts = "http://localhost:4566"
      }
}
