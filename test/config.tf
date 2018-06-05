provider "aws" {
  profile = "sandbox"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    profile        = "sandbox"
    region         = "us-east-1"
    bucket         = "state-bucket"
    key            = "cloud-core/test/storage-gateway"
    dynamodb_table = "terraform-lock"
  }

  required_version = ""
}
