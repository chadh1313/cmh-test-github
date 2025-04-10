#!/bin/bash

# Set the configmap name and namespace
configmap_name="your_configmap_name"
namespace="your_namespace"

# Create a temporary file
tmp_file=$(mktemp)

# Get the current value of the feature flag
current_value=$(kubectl get cm $configmap_name -n $namespace -o jsonpath='{.data.advserviceHighCpu}')

# Set the new value to 'false'
new_value="false"

# Edit the configmap and set the new value for the feature flag
kubectl edit cm $configmap_name -n $namespace --output-mode=jsonpath='{.data.advserviceHighCpu}' > $tmp_file

# Replace the current value with the new value
sed -i "s/$current_value/$new_value/g" $tmp_file

# Apply the changes to the configmap
kubectl apply -f $tmp_file

# Clean up the temporary file
rm $tmp_file