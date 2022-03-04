#####################################################################
##
##      Created 9/10/19 by ucdpadmin for cloud aws-brad. for role-test
##
#####################################################################

terraform {
  required_version = "> 0.8.0"
}

provider "aws" {
  assume_role {
    role_arn = "${var.role_arn}"
  }
  region = "us-east-1"
}

data "aws_s3_bucket" "selected" {
  bucket = "${var.bucket_name}"
}