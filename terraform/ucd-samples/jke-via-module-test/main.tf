#####################################################################
##
##      Created 9/27/18 by ucdpadmin. For Cloud AWS-SPB for jke-via-module-test
##
#####################################################################

## REFERENCE {"vpc":{"type": "aws_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "aws" {
  version = "~> 1.8"
}

data "aws_subnet" "subnet" {
  vpc_id = "${var.vpc_id}"
  availability_zone = "${var.availability_zone}"
}

data "aws_security_group" "group_name" {
  name = "${var.group_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_instance" "modweb1" {
  ami = "${var.modweb1_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.modweb1_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.modweb1_name}"
  }
}

resource "aws_instance" "moddb" {
  ami = "${var.modweb2_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.modweb2_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.moddb_name}"
  }
}

# Random string to key names
resource "random_pet" "env_id" {
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name   = "awskey-demo-${random_pet.env_id.id}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "null_resource" "install-java" {
  provisioner "file" {
    destination = "/tmp/install_java.sh"
    content     = <<EOT
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_java.log"
echo "---Installing java---" | tee -a $LOGFILE 2>&1
apt-get update                         >> $LOGFILE 2>&1 || { echo "---Failed to update apt-get system---" | tee -a $LOGFILE; exit 1; }
apt-get install openjdk-8-jdk -y      >> $LOGFILE 2>&1 || { echo "---Failed to install java---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOT
  }
  provisioner "remote-exec" {
     inline = [
        "chmod +x /tmp/install_java.sh; sudo bash /tmp/install_java.sh"
      ]
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
    host = "${aws_instance.modweb1.public_ip}"  # aws_instance
  }
}

resource "null_resource" "install-mariadb" {
  connection {
    user = "${var.moddb-user}"
    host = "${aws_instance.moddb.public_ip}"
    private_key = "${tls_private_key.ssh.private_key_pem}"
  }
  provisioner "file" {
    destination = "/tmp/install_mariadb.sh"
    content     = <<EOT
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_mariadb.log"
echo "---Installing mariadb---" | tee -a $LOGFILE 2>&1
yum clean all                             >> $LOGFILE 2>&1 || { echo "---Failed to update yum system---" | tee -a $LOGFILE; exit 1; }
yum -y install mariadb-server mariadb     >> $LOGFILE 2>&1 || { echo "---Failed to install mariadb---" | tee -a $LOGFILE; exit 1; }
systemctl enable mariadb                  >> $LOGFILE 2>&1 || { echo "---Failed to enable mariadb---" | tee -a $LOGFILE; exit 1; }
systemctl start mariadb                   >> $LOGFILE 2>&1 || { echo "---Failed to start mariadb---" | tee -a $LOGFILE; exit 1; }
systemctl status mariadb                  >> $LOGFILE 2>&1 || { echo "---Failed to verify status of mariadb---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOT
  }
  provisioner "remote-exec" {
     inline = [
        "chmod +x /tmp/install_mariadb.sh; sudo bash /tmp/install_mariadb.sh"
      ]
  }
}

resource "null_resource" "install-liberty" {
  depends_on = [ "null_resource.install-java" ]
  connection {
    user = "${var.modweb1-user}"
    host = "${aws_instance.modweb1.public_ip}"
    private_key = "${tls_private_key.ssh.private_key_pem}"
  }
  provisioner "file" {
    source      = "files/wlp-developers-runtime-8.5.5.3.jar"
    destination = "/tmp/wlp-developers-runtime-8.5.5.3.jar"
  }
  provisioner "file" {
    destination = "/tmp/install_liberty.sh"
    content     = <<EOT
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_liberty.log"
echo "---Installing liberty---" | tee -a $LOGFILE 2>&1
java -jar /tmp/wlp-developers-runtime-8.5.5.3.jar --acceptLicense /opt/was/liberty    >> $LOGFILE 2>&1 || { echo "---Failed to install liberty---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOT
  }
  provisioner "remote-exec" {
     inline = [
        "chmod +x /tmp/install_liberty.sh; sudo bash /tmp/install_liberty.sh"
      ]
  }
}

module "jke-ucd-app" {
  source = "git::https://github.com/chadh1313/cmh-test-github//terraform/JKE-app-only"

  ucd_user = "admin"
  ucd_password = "ec11ipse"
  ucd_server_url = "http://icdemo3.cloudy-demos.com:9080"
  environment_name = "ucd-mod-env"
  db-server_agent_name = "mod-db-agent" 
  web-server_agent_name = "mod-web-agent"
  web-server-public-ip-address = "${aws_instance.modweb1.public_ip}"
  db-server-public-ip-address = "${aws_instance.moddb.public_ip}"
  web-server-private-ssh-key = "${base64encode(tls_private_key.ssh.private_key_pem)}"
  db-server-private-ssh-key = "${base64encode(tls_private_key.ssh.private_key_pem)}"
  web-server-user = "${var.modweb1-user}"
  db-server-user = "${var.moddb-user}"
  
}
