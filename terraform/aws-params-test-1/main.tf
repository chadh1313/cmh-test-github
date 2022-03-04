#####################################################################
##
##      Created 3/7/19 by admin. For Cloud cmh-vra for aws-params-test-1
##
#####################################################################

## REFERENCE {"aws_network":{"type": "aws_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

resource "aws_instance" "aws_instance" {
  ami = "${var.aws_instance_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.aws_instance_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${var.subnet_id}"
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