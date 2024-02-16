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
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download/Install OpenShift and Kubernetes Client binary
RUN wget -O oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz && \
    tar -xzf oc.tar.gz && \
    install -m 755 oc /usr/local/bin/oc && \
    install -m 755 kubectl /usr/local/bin/kubectl && \
    rm oc.tar.gz oc kubectl README.md && \
    oc completion bash > oc_bash_completion && \
    cp oc_bash_completion /etc/bash_completion.d/

# Add .bashrc file to user's home directory
COPY files/.bashrc /root/.bashrc

USER root
