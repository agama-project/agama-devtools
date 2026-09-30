# Agama development container

This repository provides a [Dev Container](https://containers.dev/) definition
for Agama development in Visual Studio Code. It builds an openSUSE-based image
with all the tools needed for development. You can start contributing to Agama
without installing anything but Podman and VS Code on your host.

## Advantages

Developing in a containerized sandbox provides many useful advantages:

- All needed development tools are automatically installed
- Ensures all developers have the same environment
- You can develop from different version or from a completely different
  distribution (or even from Windows using WSL containers)
- The sandbox is useful when running AI code assisting tools
- If you mess up the development system you can just rebuild the container and
  start from scratch
- Want to develop on openSUSE Tumbleweed instead of Leap? Just switch the base
  system image and rebuild the container.

## Usage

There are several container definitions in this repository, each with its own
`Dockerfile` and `devcontainer.json`, located in the
[github.com/agama-project/agama/.devcontainer](github.com/agama-project/agama/.devcontainer)
directory. Pick the one matching the part of Agama you work on. Each container
uses its own named volume for the home directory, so you can use several of them
in parallel.

There are two ways how to use the definitions:

### Option 1: Copy the files to the Agama checkout

This is the simplest way, suitable for a quick start or when you do not plan to
customize the container.

1. Copy the selected container definition to the `.devcontainer` directory in
   your Agama Git checkout:

   ```sh
   cd /path/to/agama
   mkdir -p .devcontainer
   cp -r /path/to/agama-devtools/devcontainer/github.com/agama-project/agama/.devcontainer/rust .devcontainer/
   # remove .build.context value, the script is in the same directory as the Dockerfile now
   jq 'del(.build.context)' .devcontainer/devcontainer.json > .devcontainer/devcontainer.json.tmp
   mv .devcontainer/devcontainer.json.tmp .devcontainer/devcontainer.json
   ```

2. Tell Git to ignore the copied files without changing the `.gitignore`
   file (which is tracked in the Agama repository):

   ```sh
   echo "/.devcontainer/" >> .git/info/exclude
   ```

The disadvantage is that the files are not tracked anywhere. If you customize
them you need to back up your changes yourself and merge the updates from this
repository manually. The `.devcontainer` directory is also not shared between
multiple Agama checkouts (e.g. Git worktrees), you need to copy it to each of
them.

In this case you can skip the step 4 in the [Prerequisites](#prerequisites)
section below.

### Option 2: Fork this repository

This is the recommended way if you want to customize the containers and track
your changes.

1. [Fork](https://github.com/agama-project/agama-devtools/fork) this repository
   on GitHub and clone your fork:

   ```sh
   git clone git@github.com:<user>/agama-devtools.git
   cd agama-devtools
   git remote add upstream https://github.com/agama-project/agama-devtools.git
   ```

2. Configure VSCode to load the container definitions from your clone, see the
   step 4 in the [Prerequisites](#prerequisites) section below (or run the
   `./config.sh` script).

   VSCode then uses the definitions for any Agama checkout, no files are added
   to the Agama repository itself.

3. Customize the files as you want (see [Customization](#customization)) and
   commit the changes to your fork. You can easily see what you changed with
   `git diff upstream/main` and pick up the upstream changes with
   `git pull upstream main`.

4. The containers defined here are designed for the original upstream
   https://github.com/agama-project/agama repository. If you want to use the
   same dev containers for your fork then just create a symlink:

   ```sh
   ln -s agama-project github.com/<user>
   ```

## Prerequisites

You can run the `./config.sh` script from this directory to do the steps 1-4
below automatically or do them manually:

1. **Visual Studio Code** with the
   [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
   extension installed.
2. **Podman** container manager, it can be installed with
   ```shell
   sudo zypper install podman podman-compose
   ```
3. **Tell VSCode to use Podman.** This needs to be done in the user settings
   **before** you run use the container for the first time. By default VSCode
   uses Docker for the dev container but configuring and using Podman is a bit
   easier.

   Open the settings UI (`Ctrl+,`), search for
   `dev.containers.dockerPath` and `dev.containers.dockerComposePath`, and set
   both to `podman` and `podman-compose` respectively
4. **Tell VSCode where to find the devcontainer configuration.** This is needed
   only when using [Option 2](#option-2-fork-this-repository), not when you
   copied the files to the Agama checkout. The
   configuration is stored in this directory under
   `github.com/agama-project/agama/.devcontainer`, which lets the Dev Containers
   extension use it for the Agama repository.

   In the settings UI search for `dev.containers.repositoryConfigurationPaths`
   and add the path to this directory (the one containing `github.com/`) — or
   add it to the list in `settings.json`:

   ```json
   "dev.containers.repositoryConfigurationPaths": [
     "/path/to/agama-devtools/devcontainer"
   ]
   ```
   See more details in the [documentation](
   https://code.visualstudio.com/docs/devcontainers/create-dev-container#_alternative-repository-configuration-folders).
5. *(Optional, Linux only)* A running Avahi daemon on the host if you want mDNS
   hostname resolution to work inside the container. If Avahi isn't available on
   your host remove it from the `mounts` section of `devcontainer.json`.

## Opening the project in the devcontainer

1. Open your Agama repository checkout in VSCode.
2. When prompted "Reopen in Container", click it. Alternatively, open the
   Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run
   **Dev Containers: Reopen in Container**.
3. VSCode (via Podman) builds the container image the first time — this can take
   a few minutes — and then reopens the workspace inside the running container.

To rebuild the image after changing the `Dockerfile` or
`devcontainer.json`, use **Dev Containers: Rebuild Container** from the
Command Palette.

## Using the container

Once attached, open an integrated terminal and work as usual, e.g.:

```shell
# web frontend
cd web && npm install && npm run start

# Rust backend
cd rust && cargo build
```

Passwordless `sudo` is configured for the `vscode` user, if you need to install
additional packages just run `sudo zypper install`.

## Persistence

Your local copy of the Agama repository itself is bind-mounted (the default dev
containers behavior), so changes you make inside the container are reflected on
the host and are not lost when the container is rebuilt.

A volume is used for the $HOME directory so it persists between container
rebuilds. The cached files in home can then used after rebuilding the container.

All other changes you manually do in the system (e.g. installing packages) will
be lost after the next container rebuild.

## Customization

To make your changes persistent update the generated files:

- You can install additional packages or change the system by modifying the
  `Dockerfile`.
- The `devcontainer.json` contains the list of the VSCode extensions which are
  installed in the container. Again, you can change the list according to your
  needs.
- If you want to install your personal config files to $HOME use a dotfiles
  repository, see the [Dotfiles](#dotfiles) section below.

If your changes might be useful for others consider changing the original
files and creating a pull request with your changes.

### Dotfiles

Personal configuration (like shell aliases) does not belong to
the shared container definition. The Dev Containers extension can install it
from your own [dotfiles](https://dotfiles.github.io/) Git repository into every
container automatically.

1. Create a Git repository with your config files, e.g.
   `https://github.com/<user>/dotfiles`. *Do not store any secrets there!!*

2. Optionally add an install script to the repository root. The extension runs
   the first found file from `install.sh`, `install`, `bootstrap.sh`,
   `bootstrap`, `script/bootstrap`, `setup.sh`, `setup` or `script/setup`. If
   there is no such script, it symlinks all files and directories starting with
   a dot to the home directory.

3. To automatically install these dotfiles into all dev containers change the
   *Settings > Extensions > DevContainer > Dotfiles: Repository* VSCode option
   to the GitHub slug name (`<user>/<repo>`) or use a full Git URL.

4. Rebuild the container (**Dev Containers: Rebuild Container**). The repository
   is cloned inside the container and the install command is run.

See more details in the
[documentation](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories).

### Validating the changes

You can check your modified files (and the templates) before rebuilding the
container by running from this directory:

```sh
make lint-dockerfiles check-devcontainer
```

The same checks run in the GitHub CI for the templates.

The required tools can be installed with:

```sh
sudo zypper install make hadolint python3-pipx
pipx install check-jsonschema
pipx inject check-jsonschema json5
```

Or simply use the dev container for *this* repository. :smiley:

## Links

- [Dev Containers documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Advanced container configuration](https://code.visualstudio.com/remote/advancedcontainers/overview)
- [Development Containers specification](https://containers.dev/implementors/spec/)
- [Dotfiles](https://dotfiles.github.io/)
