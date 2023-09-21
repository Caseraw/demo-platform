# GitLab on OpenShift

# Prerequisites

The installation/deployment relies on a specific order as described in the
[`kustomization.yaml`](kustomization.yaml) file. The order is
[documented](https://docs.gitlab.com/operator/installation.html#prerequisites)
and requires attention.

1. Make sure Cert Manager is installed and operational.
2. Apply the [prerequisites](prerequisites).
3. Apply the [operator](operator) and wait for it to be operational.

The following scripts exists to make life a bit easier:
1. [setup_openshift-cert-manager.sh](../../scripts/setup_openshift-cert-manager.sh)
2. [setup_openshift-gitlab.sh](../../scripts/setup_openshift-gitlab.sh)

# Chart versions

Currently it's required to pass along a Helm Chart version when deploying a
`GitLab` instance. GitLab Chart versions are listed here
[here](https://docs.gitlab.com/charts/installation/version_mappings.html).
