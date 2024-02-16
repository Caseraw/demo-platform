#!/bin/env bash

# Load additional functions
source lib/display_message.sh
source lib/run_command.sh

# Install Operator
display_message "show-date" "INFO" "DevSpaces Operator" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-devspaces/operator

# Check CSV state
display_message "show-date" "INFO" "DevSpaces Operator" "Checking operator installtion state"
run_command --infinite -- oc -n openshift-operators wait ClusterServiceVersion -l operators.coreos.com/devspaces.openshift-operators --for=jsonpath='{.status.phase}'=Succeeded
run_command --infinite -- oc -n openshift-operators wait ClusterServiceVersion -l operators.coreos.com/devworkspace-operator.openshift-operators --for=jsonpath='{.status.phase}'=Succeeded

# Check CRD's
display_message "show-date" "INFO" "DevSpaces Operator" "Checking if CRD's exist"

all_crds=$(oc get crd -l operators.coreos.com/devspaces.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name)
all_crds+=$(oc get crd -l operators.coreos.com/devworkspace-operator.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name)

crds=(
  checlusters.org.eclipse.che
  devworkspaceoperatorconfigs.controller.devfile.io
  devworkspaceroutings.controller.devfile.io
  devworkspaces.workspace.devfile.io
  devworkspacetemplates.workspace.devfile.io
)

for crd in "${crds[@]}"; do
  display_message "show-date" "INFO" "DevSpaces Operator" "CRD: $crd, exists"
  if ! echo "$all_crds" | grep -q "$crd"; then
    display_message "show-date" "CRITICAL" "DevSpaces Operator" "CRD: $crd, missing!"applicationSetController
    exit 1
  fi
done

# Install CheCluster
display_message "show-date" "INFO" "DevSpaces Operator" "Applying CheCluster resource"
run_command -- oc apply -k ../kustomize/openshift-devspaces/checluster

# Check CheCluster
display_message "show-date" "INFO" "DevSpaces Operator" "Checking CheCluster state"

run_command --infinite -- oc -n openshift-devspaces wait CheCluster devspaces --for=jsonpath='{.status.chePhase}'=Active
run_command --infinite -- oc -n openshift-devspaces wait CheCluster devspaces --for=jsonpath='{.status.gatewayPhase}'=Established

# Check CheCluster workload state
display_message "show-date" "INFO" "DevSpaces Operator" "Checking CheCluster instance workload state"

pods=$(oc -n openshift-devspaces get pod --no-headers -o custom-columns=NAME:.metadata.name)

for pod in ${pods}; do
  run_command -- oc -n openshift-devspaces wait pod $pod --for=jsonpath='{.status.phase}'=Running
  run_command -- oc -n openshift-devspaces wait pod $pod --for=condition=Ready
done

# Check Web Terminal workload state
display_message "show-date" "INFO" "Web Terminal Operator" "Checking Web Terminal workload state"

run_command --infinite -- oc -n openshift-operators wait pod -l app.kubernetes.io/name=web-terminal-controller --for=jsonpath='{.status.phase}'=Running
run_command --infinite -- oc -n openshift-operators wait pod -l app.kubernetes.io/name=web-terminal-controller --for=condition=Ready

# End of checks
display_message "show-date" "INFO" "DevSpaces Operator & Web Terminal Operator" "All systems are go for OpenShift DevSpaces and Web Terminal!"
