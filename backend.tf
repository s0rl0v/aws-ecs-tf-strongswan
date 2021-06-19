terraform {
  backend "s3" {
    bucket  = "okeer-devops"
    key     = "vpn.tfstate"
    region  = "us-east-1"
    profile = "sorlov"
  }
}
