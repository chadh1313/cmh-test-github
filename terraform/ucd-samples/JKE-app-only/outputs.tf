#####################################################################
##
##      Created 4/19/18 by ucdpadmin. for JKE-app-only
##
#####################################################################
output "jke_app_url" {
  value = "http://${var.web-server-public-ip-address}:9080"
}
