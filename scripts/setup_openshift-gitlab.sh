#!/bin/env bash

# Load additional functions
source lib/display_message.sh
source lib/run_command.sh

# Install Operator
display_message "show-date" "INFO" "GitLab Operator" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-gitlab/prerequisites
run_command -- oc apply -k ../kustomize/openshift-gitlab/operator

# Check operator workload state
display_message "show-date" "INFO" "GitLab Operator" "Checking operatior workload state"
run_command --infinite -- oc -n gitlab-system wait pod -l control-plane=controller-manager --for=jsonpath='{.status.phase}'=Running
run_command --infinite -- oc -n gitlab-system wait pod -l control-plane=controller-manager --for=condition=Ready

# Check CRD's
display_message "show-date" "INFO" "GitLab Operator" "Checking if CRD's exist"

all_crds=$(oc get crd -l operators.coreos.com/gitlab-operator-kubernetes.gitlab-system --no-headers -o custom-columns=NAME:.metadata.name)

crds=(
  gitlabs.apps.gitlab.com
)

for crd in "${crds[@]}"; do
  display_message "show-date" "INFO" "GitLab Operator" "CRD: $crd, exists"
  if ! echo "$all_crds" | grep -q "$crd"; then
    display_message "show-date" "CRITICAL" "GitLab Operator" "CRD: $crd, missing!"applicationSetController
    exit 1
  fi
done

# Install GitLab instance
display_message "show-date" "INFO" "GitLab instance" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-gitlab/gitlab

# Check GitLab instance
display_message "show-date" "INFO" "GitLab instance" "Checking instance state"
run_command --infinite -- oc -n gitlab-system wait GitLab gitlab --for=jsonpath='{.status.phase}'=Running

# Cleanup
display_message "show-date" "INFO" "GitLab instance" "Cleanup completed workload"
run_command -- oc -n gitlab-system delete pod --field-selector=status.phase==Succeeded --wait=true

# Check GitLab instance workload state
display_message "show-date" "INFO" "GitLab instance" "Checking instance workload state"
run_command --infinite -- oc -n gitlab-system wait pod -l app.kubernetes.io/name=gitlab --for=jsonpath='{.status.phase}'=Running
run_command --infinite -- oc -n gitlab-system wait pod -l app.kubernetes.io/name=gitlab  --for=condition=Ready

# End of checks
display_message "show-date" "INFO" "GitLab Operator & GitLab instance" "All systems are go for GitLab Operator and Instance!"
