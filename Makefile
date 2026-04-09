# =============================================================================
# Git Chronicles — developer Makefile
#
# Entry points for local development and CI:
#   make help           list all targets
#   make install        install npm dependencies
#   make dev            run the eleventy dev server
#   make build          production build
#   make lint           run all linters (spell + i18n parity + a11y + links)
#   make test           run all verifier regression tests (bats + pester)
#   make check          lint + build + test (the full pre-commit gate)
#   make clean          remove _site/ and pagefind output
#
# Tooling expected:
#   - node + npm         (project site)
#   - bats               (bash verifier tests)
#   - pwsh + Pester      (PowerShell verifier tests — optional, skipped if
#                         pwsh is not installed; install on Arch via
#                         `yay -S powershell-bin`)
# =============================================================================

SHELL := /usr/bin/env bash

# Discover optional tooling at parse time.
BATS := $(shell command -v bats 2>/dev/null)

# PowerShell detection: try host first, then fall back to a distrobox container
# named "multidev" if it exposes pwsh (common dev setup on Arch / immutable
# distros where pwsh lives in a toolbox).
PWSH_HOST := $(shell command -v pwsh 2>/dev/null)
PWSH_DBOX := $(shell command -v distrobox >/dev/null 2>&1 && \
	distrobox enter multidev -- bash -c 'command -v pwsh' 2>/dev/null)
ifneq ($(PWSH_HOST),)
  PWSH := $(PWSH_HOST)
else ifneq ($(PWSH_DBOX),)
  PWSH := distrobox enter multidev -- pwsh
else
  PWSH :=
endif

TESTS_DIR := tests/verifiers

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# -----------------------------------------------------------------------------
# Install / dev / build
# -----------------------------------------------------------------------------

.PHONY: install
install: ## Install npm dependencies
	npm install

.PHONY: dev
dev: ## Run the eleventy dev server
	npm run dev

.PHONY: build
build: ## Production build (eleventy + minify + pagefind)
	npm run build

.PHONY: clean
clean: ## Remove generated site artifacts
	rm -rf _site pagefind

# -----------------------------------------------------------------------------
# Linters — wrap the npm scripts so contributors don't need to know them.
# -----------------------------------------------------------------------------

.PHONY: lint
lint: lint-spell lint-i18n lint-links lint-a11y ## Run all linters

.PHONY: lint-spell
lint-spell: ## Run cspell on FR + EN content
	npm run spell

.PHONY: lint-i18n
lint-i18n: ## Check FR/EN page parity
	npm run check:i18n

.PHONY: lint-links
lint-links: build ## Check internal links (requires build)
	npm run check:links

.PHONY: lint-a11y
lint-a11y: build ## Check accessibility (requires build)
	npm run check:a11y

# -----------------------------------------------------------------------------
# Verifier regression tests
# -----------------------------------------------------------------------------

.PHONY: test
test: test-bats test-pester ## Run all verifier regression tests

.PHONY: test-bats
test-bats: ## Run bats tests for verifier.sh scripts
ifeq ($(BATS),)
	@echo "✗ bats is not installed — install it to run shell verifier tests." >&2
	@exit 1
else
	@echo "▶ Running bats tests…"
	bats $(TESTS_DIR)
endif

.PHONY: test-pester
test-pester: ## Run Pester tests for verifier.ps1 scripts (skipped if pwsh absent)
ifeq ($(PWSH),)
	@echo "⚠ pwsh not found — skipping Pester tests."
	@echo "  Install on host, or provide a distrobox container named 'multidev' with pwsh."
else
	@echo "▶ Running Pester tests via: $(PWSH)"
	@$(PWSH) -NoProfile -Command " \
		if (-not (Get-Module -ListAvailable -Name Pester | Where-Object { \$$_.Version -ge '5.0.0' })) { \
			Write-Host '  Installing Pester (first run only)...'; \
			Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck; \
		} \
		Import-Module Pester; \
		\$$cfg = New-PesterConfiguration; \
		\$$cfg.Run.Path = '$(TESTS_DIR)'; \
		\$$cfg.Run.Exit = \$$true; \
		\$$cfg.Output.Verbosity = 'Detailed'; \
		Invoke-Pester -Configuration \$$cfg"
endif

# -----------------------------------------------------------------------------
# The big one — full pre-commit / CI gate.
# -----------------------------------------------------------------------------

.PHONY: check
check: lint build test ## Full gate: lint + build + tests
