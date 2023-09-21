#!/bin/sh

# Load additional functions
source lib/display_message.sh
source lib/run_command.sh

# Install Operator
display_message "show-date" "INFO" "Cert Manager Operator" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-cert-manager

# Check operator workload state
display_message "show-date" "INFO" "Cert Manager Operator" "Checking operator workload state"
run_command --infinite -- oc -n openshift-operators wait pod -l app.kubernetes.io/instance=cert-manager --for=jsonpath='{.status.phase}'=Running
run_command --infinite -- oc -n openshift-operators wait pod -l app.kubernetes.io/instance=cert-manager --for=condition=Ready

# Check CRD's
display_message "show-date" "INFO" "Cert Manager Operator" "Checking if CRD's exist"

all_crds=$(oc get crd -l app.kubernetes.io/instance=cert-manager --no-headers -o custom-columns=NAME:.metadata.name)

crds=(
  certificaterequests.cert-manager.io
  certificates.cert-manager.io
  clusterissuers.cert-manager.io
  issuers.cert-manager.io
)

for crd in "${crds[@]}"; do
  display_message "show-date" "INFO" "Cert Manager Operator" "CRD: $crd, exists"
  if ! echo "$all_crds" | grep -q "$crd"; then
    display_message "show-date" "CRITICAL" "Cert Manager Operator" "CRD: $crd, missing!"applicationSetController
    exit 1
  fi
done

# End of checks
display_message "show-date" "INFO" "Cert Manager Operator" "All systems are go for Cert Manager Operator!"
