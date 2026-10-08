SHELL := /bin/bash
.DEFAULT_GOAL := help

# ==============================================================================
# Configuration Variables
# ==============================================================================
IMAGE_NAME          ?= magicstackent/laravel-base
VERSION             ?= $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
ifeq ($(strip $(VERSION)),)
VERSION             := 1.1.0
endif
PLATFORMS           ?= linux/amd64,linux/arm64
PHP_VERSIONS        ?= 8.2 8.3 8.4 8.5
DEFAULT_PHP_VERSION ?= 8.5
DOCKERFILE          ?= Dockerfile
BUILDX_BUILDER      ?= desktop-linux

# Semantic version parts (Major, Minor, Patch)
MAJOR = $(word 1,$(subst ., ,$(VERSION)))
MINOR = $(word 2,$(subst ., ,$(VERSION)))
PATCH = $(word 3,$(subst ., ,$(VERSION)))

# Helper macro to return list of all tags for a given PHP version
define get_tags
$(IMAGE_NAME):$(1) \
$(IMAGE_NAME):$(1)-fpm-alpine \
$(IMAGE_NAME):php$(1) \
$(IMAGE_NAME):$(VERSION)-php$(1) \
$(if $(MINOR),$(IMAGE_NAME):$(MAJOR).$(MINOR)-php$(1)) \
$(IMAGE_NAME):$(MAJOR)-php$(1) \
$(if $(filter $(1),$(DEFAULT_PHP_VERSION)),\
  $(IMAGE_NAME):$(VERSION) \
  $(if $(MINOR),$(IMAGE_NAME):$(MAJOR).$(MINOR)) \
  $(IMAGE_NAME):$(MAJOR) \
  $(IMAGE_NAME):latest)
endef

# Helper macro to generate -t arguments for docker buildx
format_tag_flags = $(foreach t,$(call get_tags,$(1)),-t $(t))

# ==============================================================================
# Top-Level Targets
# ==============================================================================
.PHONY: all help list-tags build build-all push push-all check-login
.PHONY: $(addprefix build-,$(PHP_VERSIONS)) $(addprefix push-,$(PHP_VERSIONS))

all: push-all ## Build and push all images and tags for all PHP versions (Default)

help: ## Show this help message
	@echo "Laravel Base Image Build & Push Utility"
	@echo "========================================"
	@echo "Configuration:"
	@echo "  IMAGE_NAME          : $(IMAGE_NAME)"
	@echo "  VERSION             : $(VERSION) (v$(VERSION))"
	@echo "  PLATFORMS           : $(PLATFORMS)"
	@echo "  PHP_VERSIONS        : $(PHP_VERSIONS)"
	@echo "  DEFAULT_PHP_VERSION : $(DEFAULT_PHP_VERSION)"
	@echo ""
	@echo "Available Targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Per-Version Targets:"
	@for v in $(PHP_VERSIONS); do \
		printf "  \033[36m%-20s\033[0m %s\n" "build-$$v" "Build multi-arch image for PHP $$v"; \
		printf "  \033[36m%-20s\033[0m %s\n" "push-$$v" "Build and push multi-arch image with all tags for PHP $$v"; \
	done

list-tags: ## List all tags that will be generated for each PHP version
	@echo "Image Name:          $(IMAGE_NAME)"
	@echo "Release Version:     $(VERSION) (Major: $(MAJOR), Minor: $(MINOR), Patch: $(PATCH))"
	@echo "Platforms:           $(PLATFORMS)"
	@echo "Default PHP Version: $(DEFAULT_PHP_VERSION)"
	@echo "PHP Versions:        $(PHP_VERSIONS)"
	@echo ""
	@$(foreach v,$(PHP_VERSIONS),\
		echo "=== Tags for PHP $(v) ==="; \
		for t in $(call get_tags,$(v)); do \
			echo "  - $$t"; \
		done; \
		echo "";)

# ==============================================================================
# Build Targets
# ==============================================================================
build: build-all ## Build images for all PHP versions

build-all: $(addprefix build-,$(PHP_VERSIONS)) ## Build all PHP versions locally

$(addprefix build-,$(PHP_VERSIONS)): build-%:
	@echo "============================================================"
	@echo "Building multi-arch image for PHP $* [$(PLATFORMS)]"
	@echo "============================================================"
	docker buildx build \
		--platform $(PLATFORMS) \
		--file $(DOCKERFILE) \
		--build-arg PHP_VERSION=$* \
		$(call format_tag_flags,$*) \
		.
	@echo "Done building PHP $*."

# ==============================================================================
# Push Targets
# ==============================================================================
push: push-all ## Build and push images for all PHP versions

push-all: $(addprefix push-,$(PHP_VERSIONS)) ## Build and push all PHP versions with all tags

$(addprefix push-,$(PHP_VERSIONS)): push-%:
	@echo "============================================================"
	@echo "Building & Pushing multi-arch image for PHP $* [$(PLATFORMS)]"
	@echo "Tags to push:"
	@for t in $(call get_tags,$*); do echo "  - $$t"; done
	@echo "============================================================"
	docker buildx build \
		--platform $(PLATFORMS) \
		--file $(DOCKERFILE) \
		--build-arg PHP_VERSION=$* \
		$(call format_tag_flags,$*) \
		--push \
		.
	@echo "Successfully pushed all tags for PHP $*!"

# ==============================================================================
# Single-version Dynamic Targets
# ==============================================================================
.PHONY: build-php push-php

build-php: ## Build a single PHP version: make build-php PHP_VER=8.3
	@if [ -z "$(PHP_VER)" ]; then echo "Error: PHP_VER not set. Example: make build-php PHP_VER=8.3"; exit 1; fi
	$(MAKE) build-$(PHP_VER)

push-php: ## Build and push a single PHP version: make push-php PHP_VER=8.3
	@if [ -z "$(PHP_VER)" ]; then echo "Error: PHP_VER not set. Example: make push-php PHP_VER=8.3"; exit 1; fi
	$(MAKE) push-$(PHP_VER)
