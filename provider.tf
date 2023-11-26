provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "bucketarthurcisotto"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
