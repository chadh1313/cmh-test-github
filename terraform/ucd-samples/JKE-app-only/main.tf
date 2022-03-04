#####################################################################
##
##      Created 4/19/18 by ucdpadmin. for JKE-app-only
##
#####################################################################

terraform {
  required_version = "> 0.8.0"
}

provider "ucd" {
  username = "${var.ucd_user}"
  password       = "${var.ucd_password}"
  ucd_server_url = "${var.ucd_server_url}"
}

# Random string to use for environment and agent names
resource "random_pet" "env_id" {
}

##############################################################
# Install Web server agent
##############################################################
resource "null_resource" "install_web_server_agent" {
  # Specify the ssh connection
  connection {
    user = "${var.web-server-user}"
    private_key = "${base64decode(var.web-server-private-ssh-key)}"  # Generated
    host = "${var.web-server-public-ip-address}"
  }
  provisioner "ucd" {
    agent_name      = "${var.web-server_agent_name}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
      echo Going to delete an agent!
      curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.web-server_agent_name}  -X DELETE
      echo deleted an agent!
EOT
  }
}


##############################################################
# Install DB server agent
##############################################################
resource "null_resource" "install_db_server_agent" {
  # Specify the ssh connection
  connection {
    user = "${var.db-server-user}"
    private_key = "${base64decode(var.db-server-private-ssh-key)}"  # Generated
    host = "${var.db-server-public-ip-address}"  # Generated
  }
  provisioner "ucd" {
    agent_name      = "${var.db-server_agent_name}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
      echo Going to delete an agent!
      curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.db-server_agent_name}  -X DELETE
      echo deleted an agent!
EOT
  }
}

resource "ucd_component_mapping" "jke_db" {
  component = "jke.db"
  description = "jke.db Component"
  parent_id = "${ucd_agent_mapping.db-server_agent.id}"
}

resource "ucd_component_mapping" "jke_war" {
  component = "jke.war"
  description = "jke.war Component"
  parent_id = "${ucd_agent_mapping.web-server_agent.id}"
}

resource "ucd_component_process_request" "jke_db" {
  component = "jke.db"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.jke_db.id}"
  version = "LATEST"
}

resource "ucd_component_process_request" "jke_war" {
  depends_on = [ "ucd_component_process_request.jke_db" ]
  component = "jke.war"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.jke_war.id}"
  version = "LATEST"
}

resource "ucd_resource_tree" "resource_tree" {
  base_resource_group_name = "Base Resource for environment ${var.environment_name}-${random_pet.env_id.id}"
}

resource "ucd_environment" "environment" {
  name = "${var.environment_name}-${random_pet.env_id.id}"
  application = "JKE"
  base_resource_group ="${ucd_resource_tree.resource_tree.id}"
  component_property {
      component = "jke.war"
      name = "JKE_DB_HOST"
      value = "${var.db-server-public-ip-address}"  # Generated
      secure = false
  }
}

resource "ucd_agent_mapping" "db-server_agent" {
  depends_on = [ "null_resource.install_db_server_agent" ]
  description = "Agent to manage the db-server server"
  agent_name = "${var.db-server_agent_name}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}

resource "ucd_agent_mapping" "web-server_agent" {
  depends_on = [ "null_resource.install_web_server_agent" ]
  description = "Agent to manage the web-server server"
  agent_name = "${var.web-server_agent_name}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}
