#!/bin/bash
# This script examines system logs for any related error messages

# Check for errors in the system logs
grep -i "error" /var/log/syslog | less

# Check for errors in the Apache logs
grep -i "error" /var/log/apache2/access.log | less

# Check for errors in the MySQL logs
grep -i "error" /var/log/mysql/error.log | less

# Check for errors in the Nginx logs
grep -i "error" /var/log/nginx/error.log | less

# Check for errors in the system journal
journalctl -p 3 | less

# Check for errors in the systemd logs
journalctl -u <service_name> | less

# Check for errors in the Docker logs
docker logs <container_name> | less

# Check for errors in the Kubernetes logs
kubectl logs <pod_name> | less