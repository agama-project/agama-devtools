# Image Download

This directory contains scripts for downloading Agama ISO images.

You can run the scripts directly or you can install them using the `Makefile`
file. Run `make install` as regular user to install them in into our `$HOME`
directory (to `~/bin`). If started as `root` user (directly or via `sudo`) the
scripts are installed into the `/usr/bin` directory.

## `agama-download-image`

This script downloads specific Agama ISO images. It automatically handles:

- Listing the available images with details (location, date, size)
- Finding the latest version for development and testing images
- Verifying SHA256 or SHA512 checksums
- Verifying GPG signatures

**Usage:**

```bash
agama-download-image [options] [image-id]
```

**Options:**

- `--arch <arch>`: Specify the architecture (default: current system
  architecture). Supported: `x86_64`, `aarch64`, `s390x`, `ppc64le`.

- `[image-id]`: Name of the image to download. Run the script without
  arguments to see the list of available image IDs.

## `agama-image-dirs`

This script sets up a directory structure for storing different Agama images. It
creates a directory for each product/version and generates convenience wrapper
scripts (`download-online`, `download-offline`) inside them. To download an
image just run the download script inside.

**Usage:**

```bash
agama-image-dirs [target-directory]
```

**Options:**

- `[target-directory]`: Where to create the directory structure. If not
  specified it uses the `./agama-images/` path.
