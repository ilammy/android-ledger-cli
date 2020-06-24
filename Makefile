# This is the main dispatch Makefile which controls all aspects of the build.

# === Early setup ==============

# Default goal for "make"
.DEFAULT_GOAL = ledger

# Shell for target commands
SHELL = /bin/bash

# Disable built-in rules
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

## Path to build directory
BUILD ?= build

## Clean the build directory
clean:
	@rm -rf $(BUILD)

# === Git helpers ==============

# We're using submodules and it is easy to forget to check them out after
# cloning the repository. Initialize the submodules if they are missing.
check-submodules: $(BUILD)/.check-submodules

$(BUILD)/.check-submodules:
	@git submodule update --init
	@mkdir -p $(@D)
	@touch $@

# === Docker ===================

## Docker image to use
DOCKER_IMAGE ?= ilammy/android-ledger-cli:latest

## If set to "yes", force Docker image rebuild, even if the image exists locally.
DOCKER_FORCE_BUILD ?= no

## Use Docker cache. Set to "no" to force complete image rebuild.
DOCKER_CACHE ?= yes

ifeq ($(DOCKER_CACHE),no)
docker_cache_opts = --no-cache
endif

## Build Docker image
docker-image: $(BUILD)/.docker-image

# First, try pulling the latest version of the image. That might fail.
# Check if the image is available, and if not then build and tag one.
# Then check it again, now for real. If it works, create a stamp file.
$(BUILD)/.docker-image: check-submodules
	@echo "Checking $(DOCKER_IMAGE)..."
	@docker image pull $(DOCKER_IMAGE) 2>/dev/null || true
ifeq ($(DOCKER_FORCE_BUILD),yes)
	@docker build --tag=$(DOCKER_IMAGE) $(docker_cache_opts) docker && \
	 docker/scripts/prefetch-gradle.sh $(DOCKER_IMAGE)
else
	@docker run $(DOCKER_IMAGE) true || \
	 (docker build --tag=$(DOCKER_IMAGE) $(docker_cache_opts) docker && \
	  docker/scripts/prefetch-gradle.sh $(DOCKER_IMAGE))
endif
	@docker run $(DOCKER_IMAGE) true
	@echo "Docker image $(DOCKER_IMAGE) ready"
	@mkdir -p $(@D)
	@touch $@

# === Ledger ===================

# Path to resulting AAR
AAR_PATH = ledger/build/outputs/aar/ledger-release.aar

# Path to build directory inside Docker container
DOCKER_PATH = /home/user/android-ledger-cli

## Build Ledger AAR
ledger: $(AAR_PATH)

$(AAR_PATH): check-submodules docker-image
	@echo "Building Ledger..."
	@docker run --rm -v $(PWD):$(DOCKER_PATH) \
	     $(DOCKER_IMAGE) \
	     /bin/bash -c "cd $(DOCKER_PATH) && ./gradlew assembleRelease"
	@echo
	@echo "Output AAR: $@"

## Start an interactive session in Docker container.
docker-shell: check-submodules docker-image
	@docker run -it --rm -v $(PWD):$(DOCKER_PATH) $(DOCKER_IMAGE) /bin/bash || true
