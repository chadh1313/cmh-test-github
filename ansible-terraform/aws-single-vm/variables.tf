#####################################################################
##
##      Created 10/2/19 by ucdpadmin for cloud aws-brad. for aws-single-vm
##
#####################################################################

variable "ansible-runtime-host_ami" {
  type = "string"
  description = "AMI"
  default = "ami-b81dbfc5"
}

variable "instance_type" {
  type = "string"
  description = "instance type"
  default = "t2.medium"
}

variable "availability_zone" {
  type = "string"
  description = "Availabilty zone"
  default = "us-east-1a"
}

variable "instance_name" {
  type = "string"
  description = "Generated"
  default = "aws-instance"
}

variable "instance_user" {
  type = "string"
  description = "Username to access instance"
  default = "centos"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "New AWS key pair name"
  default = "aws-key"
}

variable "vpc_id" {
  type = "string"
  description = "Existing VPC ID"
  default = "vpc-6c51be09"
}

variable "group_name" {
  type = "string"
  description = "Existing security group name"
  default = "ucdev_secgroup_nva"
}

variable "instance_count" {
  type = "string"
  description = "number of instances to create"
  default = "1"
}


