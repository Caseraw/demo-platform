# Use base image
FROM docker.io/ubuntu:latest

# Set metadata
LABEL maintainer="Caseraw"

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        bash-completion \
        git \
        wget \
        jq \
        tree \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download/Install OpenShift and Kubernetes Client binary
RUN wget -O oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz && \
    tar -xzf oc.tar.gz && \
    install -m 755 oc /usr/local/bin/oc && \
    install -m 755 kubectl /usr/local/bin/kubectl && \
    oc completion bash > oc_bash_completion && \
    cp oc_bash_completion /etc/bash_completion.d/ && \
    rm -rf oc.tar.gz oc kubectl README.md oc_bash_completion

# Download/Install Kustomize Client binary
RUN wget -O kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.3.0/kustomize_v5.3.0_linux_amd64.tar.gz && \
    tar -xzf kustomize.tar.gz && \
    install -m 755 kustomize /usr/local/bin/kustomize && \
    kustomize completion bash > kustomize_bash_completion && \
    cp kustomize_bash_completion /etc/bash_completion.d/ && \
    rm -rf kustomize.tar.gz kustomize kustomize_bash_completion

# Download/Install Helm Client binary
RUN wget -O helm.tar.gz https://get.helm.sh/helm-v3.14.2-linux-amd64.tar.gz && \
    tar -xzf helm.tar.gz && \
    install -m 755 linux-amd64/helm /usr/local/bin/helm && \
    helm completion bash > helm_bash_completion && \
    cp helm_bash_completion /etc/bash_completion.d/ && \
    rm -rf helm.tar.gz linux-amd64

# Add .bashrc file to user's home directory
COPY files/.bashrc /root/.bashrc

USER root
