terraform {
  backend "s3" {

    bucket = "burkiterraformstate98"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}