#!/bin/bash
#
# Prepare the host for running the dev container, automates the steps from the
# "Prerequisites" section in README.md:
#
# 1. Installs the Dev Containers extension into Visual Studio Code
# 2. Installs Podman and podman-compose
# 3. Configures VSCode to use Podman instead of Docker and adds this directory
#    (containing the github.com/... configuration) to the dev container
#    repository configuration paths
# 4. Checks whether the Avahi daemon socket is available for the mDNS mount
#
# The script can be safely run repeatedly, already done steps are skipped.

set -euo pipefail

extension=ms-vscode-remote.remote-containers
settings="$HOME/.config/Code/User/settings.json"
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# install the missing packages via zypper
install_packages() {
  if ! command -v zypper > /dev/null; then
    echo "error: zypper not found, install these packages manually: $*" >&2
    exit 1
  fi

  echo "installing: $*"
  sudo zypper --non-interactive install "$@"
}

# 1. Visual Studio Code with the Dev Containers extension
if ! command -v code > /dev/null; then
  echo "error: Visual Studio Code (the \"code\" command) not found," >&2
  echo "       install it from https://code.visualstudio.com/ first" >&2
  exit 1
fi

if code --list-extensions | grep -qix "$extension"; then
  echo "skip:    $extension extension already installed"
else
  code --install-extension "$extension"
fi

# 2. Podman
packages=()
for cmd in podman podman-compose jq; do
  command -v "$cmd" > /dev/null || packages+=("$cmd")
done

if [ ${#packages[@]} -eq 0 ]; then
  echo "skip:    podman, podman-compose and jq already installed"
else
  install_packages "${packages[@]}"
fi

# 3. Tell VSCode to use Podman and where to find the configuration
mkdir -p "$(dirname "$settings")"
[ -s "$settings" ] || echo '{}' > "$settings"

# keep the existing repository configuration paths, add this directory only
# when missing ($repo is a jq variable, not a shell variable)
# shellcheck disable=SC2016
update='
  ."dev.containers.dockerPath" = "podman"
  | ."dev.containers.dockerComposePath" = "podman-compose"
  | ."dev.containers.repositoryConfigurationPaths" |= (
      (. // []) | if any(.[]; . == $repo) then . else . + [$repo] end
    )'

if ! current=$(jq --arg repo "$repo" "($update) == ." "$settings"); then
  echo "error: cannot parse $settings (comments or trailing commas are not" >&2
  echo "       supported by jq), add these settings manually:" >&2
  echo '         "dev.containers.dockerPath": "podman",' >&2
  echo '         "dev.containers.dockerComposePath": "podman-compose",' >&2
  echo "         \"dev.containers.repositoryConfigurationPaths\": [\"$repo\"]" >&2
  exit 1
fi

if [ "$current" = "true" ]; then
  echo "skip:    VSCode already configured"
else
  if ! jq --arg repo "$repo" "$update" "$settings" > "$settings.new"; then
    rm -f "$settings.new"
    exit 1
  fi
  mv "$settings.new" "$settings"
  echo "updated: $settings"
fi

# 4. The Avahi daemon socket, bind mounted into some containers for mDNS
avahi_socket=/run/avahi-daemon/socket
if [ -S "$avahi_socket" ]; then
  echo "skip:    Avahi socket $avahi_socket found"
else
  mapfile -t avahi_files < <(grep -rl --include=devcontainer.json \
    "source=/run/avahi-daemon" "$repo/github.com" | sort)

  if [ ${#avahi_files[@]} -gt 0 ]; then
    echo "Warning: Avahi socket $avahi_socket not found, the containers would" >&2
    echo "         fail to start. Install and start the Avahi daemon or remove" >&2
    echo "         the /run/avahi-daemon mount from these files:" >&2
    printf '           %s\n' "${avahi_files[@]}" >&2
  fi
fi
