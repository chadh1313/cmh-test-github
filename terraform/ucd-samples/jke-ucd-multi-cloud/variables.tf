#####################################################################
##
##      Created 3/13/18 by ucdpadmin. for multi-cloud-mysql-liberty
##
#####################################################################

# AWS
variable "aws_access_id" {
  type = "string"
  description = "Generated"
}

variable "aws_secret_key" {
  type = "string"
  description = "Generated"
}

variable "region" {
  type = "string"
  description = "Generated"
}

variable "web-server_ami" {
  type = "string"
  description = "Generated"
}

variable "web-server_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "web-server_availability_zone" {
  type = "string"
  description = "Generated"
}

variable "web-server_name" {
  type = "string"
  description = "Generated"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
}

variable "group_name" {
  type = "string"
  description = "Generated"
}

variable "ibm_sl_username" {
  type = "string"
  description = "Generated"
}

variable "ibm_sl_api_key" {
  type = "string"
  description = "Generated"
}

variable "vm_instance_domain" {
  type = "string"
  description = "The domain for the computing instance."
}

variable "vm_instance_hostname" {
  type = "string"
  description = "The hostname for the computing instance."
}

variable "vm_instance_datacenter" {
  type = "string"
  description = "The datacenter in which you want to provision the instance. NOTE: If dedicated_host_name or dedicated_host_id is provided then the datacenter should be same as the dedicated host datacenter."
}

variable "vm_instance_os_reference_code" {
  type = "string"
  description = "Generated"
}

variable "softlayer-vlan_public_vlan_id" {
  type = "string"
  description = "Generated"
}

variable "softlayer-vlan_private_vlan_id" {
  type = "string"
  description = "Generated"
}

variable "ucd_user" {
  type = "string"
  description = "UCD User."
  default = "admin"
}

variable "ucd_password" {
  type = "string"
  description = "UCD Password."
  default = ""
}

variable "ucd_server_url" {
  type = "string"
  description = "UCD Server URL."
  default = "http://icdemo3.cloudy-demos.com:9080"
}

variable "environment_name" {
  type = "string"
  description = "Generated"
}

variable "db-server_agent_name" {
  type = "string"
  description = "agent name"
}

variable "web-server_agent_name" {
  type = "string"
  description = "agent name"
}
