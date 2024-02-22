#!/bin/env bash

# OpenShift Cluster Prep
source demo_prep.sh

# OpenShift GitOps
source setup_openshift-gitops.sh

# OpenShift DevSpaces
source setup_openshift-devspaces.sh

# OpenShift Cert Manager
source setup_openshift-cert-manager.sh
