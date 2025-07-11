terraform {
  backend "s3" {
    bucket = "stein321-tfstate"
    key    = "terraform-mon.tfstate"
    region = "us-west-2"
  }
}