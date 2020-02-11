terraform {
  backend "gcs" {
      bucket = "justin-terraformer-gcs"
      prefix = "terraform-gcs-test"
      credentials = "/Users/justin/Downloads/justin-terraformer-gcs.json"
  }
}

provider "google" {
  credentials = file("/Users/justin/Downloads/justin-terraformer-gcs.json")
  project = "cloud-armory"
  region = "us-central1"
  zone = "us-central1-c"
}

resource "google_storage_bucket" "test" {
    name = "armory-justin-${var.bucket_postfix}"
    location = "US"
}

variable "bucket_postfix" {
  default = "helloworld"
}

output "bucket" {
    value = "${google_storage_bucket.test.name}"
}
