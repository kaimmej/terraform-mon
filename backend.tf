terraform {
  backend "s3" {
    bucket = "terraformmon"
    key    = "terraform-mon.tfstate"
    region = "us-west-2"
  }
}