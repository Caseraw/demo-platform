#!/bin/sh

# Load additional functions
source lib/display_message.sh
source lib/run_command.sh

# Install Operator
display_message "show-date" "INFO" "OpenShift Cluster Prep" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-cluster-prep
