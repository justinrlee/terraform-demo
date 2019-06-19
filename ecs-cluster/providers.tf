terraform {
  backend "s3" {
      bucket = "armory-dev-justin"
      key = "terraform-demo/ecs-cluster"
      region = "us-east-1"
      profile = "terraform"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
