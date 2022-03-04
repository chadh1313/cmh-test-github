#####################################################################
##
##      Created 3/13/18 by ucdpadmin. for multi-cloud-mysql-liberty
##
#####################################################################

# JKE Web Server IP address
output "web_server_ip_address" {
  value = "${aws_instance.web-server.public_ip}"
}
output "db_server_ip_address" {
  value = "${ibm_compute_vm_instance.db-server.ipv4_address}"
}
output "jke_app_url" {
  value = "http://${aws_instance.web-server.public_ip}:9080"
}