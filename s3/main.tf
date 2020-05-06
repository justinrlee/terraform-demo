terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "us-west-2"
}

variable "environment_name" {
  default = "hello"
}

resource "aws_s3_bucket" "b" {
  bucket = "terraformer-demo-${var.environment_name}"
  acl    = "public-read"

  tags = {
    Name = "Bucket for ${var.environment_name}"
  }
}

output "test_output" {
    value = "${aws_s3_bucket.b.arn}"
}
