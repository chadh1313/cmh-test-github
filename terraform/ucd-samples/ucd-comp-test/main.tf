#####################################################################
##
##      Created 4/18/19 by ucdpadmin. For Cloud aws-chadh for ucd-comp-test
##
#####################################################################

## REFERENCE {"aws_network":{"type": "aws_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "aws" {
  version = "~> 1.8"
}

provider "ucd" {
  username       = "${var.ucd_user}"
  password       = "${var.ucd_password}"
  ucd_server_url = "${var.ucd_server_url}"
}


data "aws_subnet" "subnet" {
  vpc_id = "${var.vpc_id}"
  availability_zone = "${var.availability_zone}"
}

data "aws_security_group" "group_name" {
  name = "${var.group_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_instance" "aws_instance" {
  ami = "${var.aws_instance_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.aws_instance_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
  provisioner "ucd" {
    agent_name      = "${var.aws_instance_agent_name}.${random_id.stack.hex}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.aws_instance_agent_name}.${random_id.stack.hex} -X DELETE
EOT
}
  tags {
    Name = "${var.aws_instance_name}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "ucd_component_mapping" "WebSphere_Liberty_Profile_aws_instance" {
  component = "WebSphere Liberty Profile"
  description = "WebSphere Liberty Profile Component"
  parent_id = "${ucd_agent_mapping.aws_instance_agent.id}"
}

resource "ucd_component_mapping" "jke_war_aws_instance" {
  component = "jke.war"
  description = "jke.war Component"
  parent_id = "${ucd_agent_mapping.aws_instance_agent.id}"
}

resource "random_id" "stack" {
  byte_length = 6
}

resource "ucd_component_process_request" "WebSphere_Liberty_Profile_aws_instance" {
  component = "WebSphere Liberty Profile"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.WebSphere_Liberty_Profile_aws_instance.id}"
  version = "LATEST"
}

resource "ucd_component_process_request" "jke_war_aws_instance" {
  component = "jke.war"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.jke_war_aws_instance.id}"
  version = "LATEST"
}

resource "ucd_resource_tree" "resource_tree" {
  base_resource_group_name = "Base Resource for environment ${var.environment_name}-${random_id.stack.hex}"
}

resource "ucd_environment" "environment" {
  name = "${var.environment_name}-${random_id.stack.hex}"
  application = "JKE"
  base_resource_group ="${ucd_resource_tree.resource_tree.id}"
  component_property {
      component = "WebSphere Liberty Profile"
      name = "testenv"
      value = "testme"
      secure = false
  }
  component_property {
      component = "jke.war"
      name = "testenv"
      value = "testval"
      secure = false
  }
  component_property {
      component = "jke.war"
      name = "JKE_DB_HOST"
      value = "localhost"
      secure = false
  }
}

resource "ucd_agent_mapping" "aws_instance_agent" {
  depends_on = [ "aws_instance.aws_instance" ]
  description = "Agent to manage the aws_instance server"
  agent_name = "${var.aws_instance_agent_name}.${random_id.stack.hex}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}