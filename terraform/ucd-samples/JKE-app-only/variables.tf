#####################################################################
##
##      Created 4/19/18 by ucdpadmin. for JKE-app-only
##
#####################################################################

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
  description = "UCD Server URL"
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

variable "web-server-public-ip-address" {
  type = "string"
  description = "Generated"
}

variable "db-server-public-ip-address" {
  type = "string"
  description = "Generated"
}

variable "web-server-private-ssh-key" {
  type = "string"
  description = "Generated"
}

variable "db-server-private-ssh-key" {
  type = "string"
  description = "Generated"
}

variable "web-server-user" {
  type = "string"
  description = "Generated"
  default = "ubuntu"
}

variable "db-server-user" {
  type = "string"
  description = "Generated"
  default = "root"
}
