#!/bin/bash

# Initialize the dev container, called from the "postCreateCommand" in
# devcontainer.json after the container is created.

set -euo pipefail

# trust the /workspaces directory in Git, avoid adding duplicate entries
if ! git config --global --get-all safe.directory | grep -qxF /workspaces; then
  git config --global --add safe.directory /workspaces
fi

# trust the /workspaces directory in Gemini
mkdir -p ~/.gemini
file=~/.gemini/trustedFolders.json
if [ -f "$file" ]; then
  # Use a temporary file to safely update with jq
  jq '."/workspaces" = "TRUST_FOLDER"' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
else
  echo '{"/workspaces": "TRUST_FOLDER"}' > "$file"
fi
