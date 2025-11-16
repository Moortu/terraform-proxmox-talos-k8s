SHELL := /bin/bash

STACKS_DIR ?= stacks/production
TM_FLAGS   ?= --enable-sharing
TF_BIN     ?= tofu
TF_APPLY_FLAGS   ?= --auto-approve
TF_DESTROY_FLAGS ?= --auto-approve

TAGS      ?=
TAGS_OPTS := $(foreach t,$(TAGS),--tags $(t))

APPLY_TAGS      ?= iso vms talos-config
APPLY_TAGS_OPTS := $(foreach t,$(APPLY_TAGS),--tags $(t))

.PHONY: help apply destroy apply-all destroy-all apply-bootstrap destroy-bootstrap apply-with-tags destroy-with-tags init upgrade

help:
	@echo "make apply                 # apply iso vms talos-config"
	@echo "make destroy               # destroy iso vms talos-config"
	@echo "make apply-all             # apply all stacks"
	@echo "make destroy-all           # destroy all stacks (reverse order)"
	@echo "make apply-bootstrap       # apply only bootstrap stack"
	@echo "make destroy-bootstrap     # destroy only bootstrap stack"
	@echo "make apply-with-tags TAGS='tag1 tag2'     # apply selected tags"
	@echo "make destroy-with-tags TAGS='tag1 tag2'   # destroy selected tags (reverse order)"
	@echo "make init                  # run 'tofu init' across stacks (optionally limit with TAGS)"
	@echo "make upgrade               # run 'tofu init -upgrade' across stacks (optionally limit with TAGS)"
	@echo "Variables: STACKS_DIR=$(STACKS_DIR) TM_FLAGS=$(TM_FLAGS) TF_BIN=$(TF_BIN)"

apply:
	cd $(STACKS_DIR) && terramate run $(TM_FLAGS) $(APPLY_TAGS_OPTS) -- $(TF_BIN) apply $(TF_APPLY_FLAGS)

destroy:
	cd $(STACKS_DIR) && terramate run --reverse $(TM_FLAGS) $(APPLY_TAGS_OPTS) -- $(TF_BIN) destroy $(TF_DESTROY_FLAGS)

apply-all:
	cd $(STACKS_DIR) && terramate run $(TM_FLAGS) -- $(TF_BIN) apply $(TF_APPLY_FLAGS)

destroy-all:
	cd $(STACKS_DIR) && terramate run --reverse $(TM_FLAGS) -- $(TF_BIN) destroy $(TF_DESTROY_FLAGS)

apply-bootstrap:
	cd $(STACKS_DIR) && terramate run $(TM_FLAGS) --tags bootstrap -- $(TF_BIN) apply $(TF_APPLY_FLAGS)

destroy-bootstrap:
	cd $(STACKS_DIR) && terramate run --reverse $(TM_FLAGS) --tags bootstrap -- $(TF_BIN) destroy $(TF_DESTROY_FLAGS)

apply-with-tags:
	cd $(STACKS_DIR) && terramate run $(TM_FLAGS) $(TAGS_OPTS) -- $(TF_BIN) apply $(TF_APPLY_FLAGS)

destroy-with-tags:
	cd $(STACKS_DIR) && terramate run --reverse $(TM_FLAGS) $(TAGS_OPTS) -- $(TF_BIN) destroy $(TF_DESTROY_FLAGS)

init:
	cd $(STACKS_DIR) && terramate run $(TM_FLAGS) $(TAGS_OPTS) -- $(TF_BIN) init

upgrade:
	cd $(STACKS_DIR) && terramate run $(TM_FLAGS) $(TAGS_OPTS) -- $(TF_BIN) init -upgrade
