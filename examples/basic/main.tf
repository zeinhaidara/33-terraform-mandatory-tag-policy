terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.73.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "reports_bucket" {
  source = "../.."

  bucket_name = "reports-example-com"
  tags = {
    cost-center = "CC-1234"
    owner       = "platform@example.com"
    environment = "dev"
    project     = "billing-reports"
  }
}

output "bucket_tags" {
  value = module.reports_bucket.tags
}
