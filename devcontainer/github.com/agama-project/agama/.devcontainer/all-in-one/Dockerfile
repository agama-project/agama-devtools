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

ARG RUST_PACKAGES="\
    cargo \
    cargo-audit \
    clang-devel \
    gcc \
    gcc-c++ \
    jsonnet \
    libpwquality-tools \
    libsuseconnect \
    libzypp-devel \
    lshw \
    NetworkManager \
    openssl-devel \
    pam-devel \
    python-langtable-data \
    rust \
    rust-bindgen \
    timezone \
    xkeyboard-config-lang"

ARG RUBY_PACKAGES="\
    augeas-devel \
    ruby-devel"

ARG KIWI_PACKAGES="\
    bats \
    python3-kiwi"

# Install tools required by VS Code Remote Development and some base development tools
RUN zypper --non-interactive install --no-recommends --allow-downgrade \
    $BASE_PACKAGES $EXTRA_PACKAGES $NODE_PACKAGES $RUBY_PACKAGES $RUST_PACKAGES $KIWI_PACKAGES \
    && zypper clean -a

# Ruby language server
RUN gem install --no-format-exec ruby-lsp

# Comment the block below when NOT using the Claude extension with Vertex AI login
RUN zypper ar -f https://packages.cloud.google.com/yum/repos/cloud-sdk-el10-x86_64 google-cloud-rhel10
RUN zypper --non-interactive --gpg-auto-import-keys install --no-recommends \
    google-cloud-cli \
    && zypper clean -a

# Set up a non-root user (recommended for dev containers), configure passwordless sudo
ARG USERNAME=vscode
RUN useradd -s /bin/bash --uid 1000 --gid users -m $USERNAME \
    && mkdir -p /etc/sudoers.d/ \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the default user
USER $USERNAME
