SCRIPTS := $(wildcard *.sh)
SHFMT_OPTIONS := -i 2 -sr -ci

# all container definitions, additional files can be checked via the
# EXTRA_* variables
DOCKERFILES := $(sort $(shell find github.com -name Dockerfile -type f)) $(EXTRA_DOCKERFILES)
DEVCONTAINER_FILES := $(sort $(shell find github.com -name devcontainer.json -type f)) \
  $(EXTRA_DEVCONTAINER_FILES)

# schema for validating the devcontainer.json files
DEVCONTAINER_SCHEMA := https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.base.schema.json

.PHONY: check format reformat lint-dockerfiles check-devcontainer

# run shellcheck on all scripts
check:
	shellcheck $(SCRIPTS)

# check the formatting of the scripts, print the diff if not formatted properly
format:
	shfmt $(SHFMT_OPTIONS) -d $(SCRIPTS)

# format the scripts in place
reformat:
	shfmt $(SHFMT_OPTIONS) -w $(SCRIPTS)

# lint the Dockerfiles, see .hadolint.yaml for the configuration
lint-dockerfiles:
	hadolint --config .hadolint.yaml $(DOCKERFILES)

# validate the devcontainer.json files against the schema, the files are
# JSONC (JSON with comments) so parse them as JSON5
check-devcontainer:
	check-jsonschema --force-filetype json5 --schemafile $(DEVCONTAINER_SCHEMA) $(DEVCONTAINER_FILES)
