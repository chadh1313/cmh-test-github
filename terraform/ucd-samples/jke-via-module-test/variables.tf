#####################################################################
##
##      Created 9/27/18 by ucdpadmin. For Cloud AWS-SPB for jke-via-module-test
##
#####################################################################

variable "modweb1_ami" {
  type = "string"
  description = "Generated"
  default = "ami-b81dbfc5"
}

variable "modweb1_aws_instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
  default = "us-east-1a"
}

variable "modweb1_name" {
  type = "string"
  description = "Generated"
  default = "jkewebmod1"
}

variable "modweb2_ami" {
  type = "string"
  description = "Generated"
  default = "ami-759bc50a"
}

variable "modweb2_aws_instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "group_name" {
  type = "string"
  description = "Generated"
  default = "ucdev_secgroup_nva"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
  default = "vpc-6c51be09"
}

variable "moddb_name" {
  type = "string"
  description = "Generated"
  default = "jkedbmod1"
}

variable "moddb-user" {
  type = "string"
  description = "Generated"
  default = "centos"
}

variable "modweb1-user" {
  type = "string"
  description = "Generated"
  default = "ubuntu"
}

