# Use the openSUSE Leap 16.0 base image
FROM registry.opensuse.org/opensuse/leap:16.0

# Alternatively you can use openSUSE Tumbleweed
# FROM registry.opensuse.org/opensuse/tumbleweed:latest

ARG BASE_PACKAGES="\
    bash-completion \
    command-not-found \
    curl \
    diffutils \
    findutils \
    gawk \
    git \
    glibc-locale-base \
    gpg2 \
    grep \
    gzip \
    jq \
    make \
    openssh-clients \
    patch \
    procps \
    ripgrep \
    shadow \
    ShellCheck \
    shfmt \
    sudo \
    tar \
    wdiff \
    wget \
    which \
    xz \
    yq"

ARG EXTRA_PACKAGES="\
    gettext-tools \
    nss-mdns"

ARG NODE_PACKAGES="\
    nodejs \
    npm"

# Install tools required by VS Code Remote Development and some base development tools
RUN zypper --non-interactive install --no-recommends --allow-downgrade \
    $BASE_PACKAGES $EXTRA_PACKAGES $NODE_PACKAGES \
    && zypper clean -a

# Set up a non-root user (recommended for dev containers), configure passwordless sudo
ARG USERNAME=vscode
RUN useradd -s /bin/bash --uid 1000 --gid users -m $USERNAME \
    && mkdir -p /etc/sudoers.d/ \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install the initialization script
COPY container-init.sh /usr/local/bin/

# Set the default user
USER $USERNAME
