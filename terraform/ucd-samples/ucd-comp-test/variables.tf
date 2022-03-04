#####################################################################
##
##      Created 4/18/19 by ucdpadmin. For Cloud aws-chadh for ucd-comp-test
##
#####################################################################


variable "aws_instance_ami" {
  type = "string"
  description = "Generated"
  default = "ami-759bc50a"
}

variable "aws_instance_aws_instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
  default = "us-east-1a"
}

variable "aws_instance_name" {
  type = "string"
  description = "Generated"
  default = "comptestvm"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
  default = "comptestkey"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
  default = "vpc-6c51be09"
}

variable "group_name" {
  type = "string"
  description = "Generated"
  default = "ucdev_secgroup_nva"
}

variable "ucd_user" {
  type = "string"
  description = "UCD user"
  default = "admin"
}

variable "ucd_password" {
  type = "string"
  description = "UCD password"
}

variable "ucd_server_url" {
  type = "string"
  description = "UCD server URL"
  default = "http://54.89.250.86:9080"
}

variable "environment_name" {
  type = "string"
  description = "Environment name"
  default = "comptestenv"
}

variable "aws_instance_agent_name" {
  type = "string"
  description = "Agent name"
  default = "comptestagent"
}

