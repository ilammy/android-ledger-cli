# This is the main dispatch Makefile which controls all aspects of the build.

# === Early setup ==============

# Default goal for "make"
.DEFAULT_GOAL = docker-image

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

## Build Docker image
docker-image: $(BUILD)/.docker-image

# First, try pulling the latest version of the image. That might fail.
# Check if the image is available, and if not then build and tag one.
# Then check it again, now for real. If it works, create a stamp file.
$(BUILD)/.docker-image: check-submodules
	@docker image pull --quiet $(DOCKER_IMAGE) 2>/dev/null || true
	@docker run $(DOCKER_IMAGE) true || \
	 docker build --tag=$(DOCKER_IMAGE) docker
	@docker run $(DOCKER_IMAGE) true
	@echo "Docker image $(DOCKER_IMAGE) ready"
	@mkdir -p $(@D)
	@touch $@
