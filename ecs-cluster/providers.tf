terraform {
  backend "s3" {
      bucket = "armory-sales-justin"
      key = "terraform-demo/ecs-cluster"
      region = "us-east-1"
      profile = "armory-sales"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "armory-sales"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
