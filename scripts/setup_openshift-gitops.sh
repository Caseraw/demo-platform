#!/bin/env bash

# Load additional functions
source lib/display_message.sh
source lib/run_command.sh

# Install Operator
display_message "show-date" "INFO" "OpenShift GitOps" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-gitops/operator

# Check CSV state
display_message "show-date" "INFO" "OpenShift GitOps" "Checking operator installtion state"
run_command --infinite -- oc -n openshift-operators wait ClusterServiceVersion -l operators.coreos.com/openshift-gitops-operator.openshift-operators --for=jsonpath='{.status.phase}'=Succeeded

# Check CRD's
display_message "show-date" "INFO" "OpenShift GitOps" "Checking if CRD's exist"

all_crds=$(oc get crd -l operators.coreos.com/openshift-gitops-operator.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name)

crds=(
  applications.argoproj.io
  applicationsets.argoproj.io
  appprojects.argoproj.io
  argocds.argoproj.io
)

for crd in "${crds[@]}"; do
  display_message "show-date" "INFO" "OpenShift GitOps" "CRD: $crd, exists"
  if ! echo "$all_crds" | grep -q "$crd"; then
    display_message "show-date" "CRITICAL" "OpenShift GitOps" "CRD: $crd, missing!"
    exit 1
  fi
done

# Check ArgoCD instance state
display_message "show-date" "INFO" "OpenShift GitOps" "Checking GitOps ArgoCD instance state"
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.phase}'=Available
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.applicationController}'=Running
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.applicationSetController}'=Running
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.redis}'=Running
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.repo}'=Running
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.server}'=Running
run_command --infinite -- oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.sso}'=Running

# Check ArgoCD instance workload state
display_message "show-date" "INFO" "OpenShift GitOps" "Checking GitOps ArgoCD instance workload state"

pods=$(oc -n openshift-gitops get pod --no-headers -o custom-columns=NAME:.metadata.name)

for pod in ${pods}; do
  run_command -- oc -n openshift-gitops wait pod $pod --for=jsonpath='{.status.phase}'=Running
  run_command -- oc -n openshift-gitops wait pod $pod --for=condition=Ready
done

# Configure GitOps ArgoCD
display_message "show-date" "INFO" "Configure GitOps ArgoCD" "Applying kustomize resources"
run_command -- oc apply -k ../kustomize/openshift-gitops/config

# Add GitOps ArgoCD app-of-apps
display_message "show-date" "INFO" "Add GitOps ArgoCD app-of-apps" "Applying cluster config app-of-apps"
run_command -- oc apply -f ../kustomize/openshift-cluster-config/app-of-apps/app-of-apps.yaml

# End of checks
display_message "show-date" "INFO" "OpenShift GitOps" "All systems are go for OpenShift GitOps!"
