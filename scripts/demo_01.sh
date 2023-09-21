#!/bin/env bash

# OpenShift Cluster Prep
source demo_prep.sh

# OpenShift Cert Manager
source setup_openshift-cert-manager.sh

# OpenShift GitLab
source setup_openshift-gitlab.sh

# OpenShift GitLab Config
source configure_openshift-gitlab.sh
