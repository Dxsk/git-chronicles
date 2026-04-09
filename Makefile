# =============================================================================
# Git Chronicles, developer Makefile
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
#   make package        build the release zip locally (see docs/RELEASING.md)
#
# Tooling expected:
#   - node + npm         (project site)
#   - bats               (bash verifier tests)
#   - pwsh + Pester      (PowerShell verifier tests, optional, skipped if
#                         pwsh is not installed; install on Arch via
#                         `yay -S powershell-bin`)
#
# Non-trivial shell logic lives under scripts/makefile/ so this file
# stays readable. Add new helpers there rather than growing recipes.
# =============================================================================

SHELL := /usr/bin/env bash

# Discover optional tooling at parse time.
BATS := $(shell command -v bats 2>/dev/null)

# PowerShell detection delegated to a helper script (host first,
# distrobox 'multidev' fallback). Empty string means not available.
PWSH := $(shell scripts/makefile/detect-pwsh.sh)

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
	rm -rf _site pagefind build

.PHONY: package
package: ## Build release zip locally (same output as CI)
	./scripts/package-release.sh

# -----------------------------------------------------------------------------
# Linters: wrap the npm scripts so contributors don't need to know them.
# -----------------------------------------------------------------------------

.PHONY: lint
lint: lint-spell lint-i18n lint-links lint-a11y lint-shell lint-ci lint-powershell ## Run all linters

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

.PHONY: lint-shell
lint-shell: ## Run shellcheck on bash scripts and verifiers
	@scripts/makefile/run-shellcheck.sh

.PHONY: lint-ci
lint-ci: ## Run actionlint on .github/workflows (skipped if absent)
	@scripts/makefile/run-actionlint.sh

.PHONY: lint-powershell
lint-powershell: ## Run PSScriptAnalyzer on .ps1 files (skipped if pwsh absent)
ifeq ($(PWSH),)
	@echo "⚠ pwsh not found, skipping PSScriptAnalyzer."
else
	@scripts/makefile/run-psscriptanalyzer.sh $(PWSH)
endif

# -----------------------------------------------------------------------------
# Dependency health: audit and outdated.
# Kept separate from `lint` because they depend on the network and on an
# up-to-date npm registry, which makes them flaky for a commit-time gate.
# -----------------------------------------------------------------------------

.PHONY: deps
deps: audit outdated ## Run all dependency health checks

.PHONY: audit
audit: ## Run npm audit (production deps only, fails on any vulnerability)
	npm audit --omit=dev

.PHONY: outdated
outdated: ## Show outdated npm dependencies (informational, never fails)
	@npm outdated || true

# -----------------------------------------------------------------------------
# Verifier regression tests
# -----------------------------------------------------------------------------

.PHONY: test
test: test-bats test-pester test-packaging ## Run all regression tests

.PHONY: test-bats
test-bats: ## Run bats tests for verifier.sh scripts
ifeq ($(BATS),)
	@echo "✗ bats is not installed, install it to run shell verifier tests." >&2
	@exit 1
else
	@echo "▶ Running bats tests…"
	bats $(TESTS_DIR)
endif

.PHONY: test-pester
test-pester: ## Run Pester tests for verifier.ps1 scripts (skipped if pwsh absent)
ifeq ($(PWSH),)
	@echo "⚠ pwsh not found, skipping Pester tests."
	@echo "  Install on host, or provide a distrobox container named 'multidev' with pwsh."
else
	@scripts/makefile/run-pester.sh $(TESTS_DIR) $(PWSH)
endif

.PHONY: test-packaging
test-packaging: ## Run bats tests for the release packaging script
ifeq ($(BATS),)
	@echo "✗ bats is not installed, skipping packaging tests." >&2
else
	@echo "▶ Running packaging tests…"
	bats tests/packaging
endif

# -----------------------------------------------------------------------------
# Meta targets: umbrella commands for common maintenance flows.
# -----------------------------------------------------------------------------

.PHONY: check
check: lint build test ## Commit-time gate: lint + build + tests

.PHONY: pre-push
pre-push: check deps ## Pre-push gate: check + dependency health

.PHONY: fresh
fresh: clean install build ## Nuke build artifacts, reinstall deps, rebuild from scratch

.PHONY: doctor
doctor: ## Verify required and optional local tooling is installed
	@echo "▶ Checking local tooling…"
	@printf '  %-18s ' "node";        command -v node        >/dev/null 2>&1 && node --version        || echo "✗ missing (required)"
	@printf '  %-18s ' "npm";         command -v npm         >/dev/null 2>&1 && npm --version         || echo "✗ missing (required)"
	@printf '  %-18s ' "bats";        command -v bats        >/dev/null 2>&1 && bats --version        || echo "✗ missing (required for make test)"
	@printf '  %-18s ' "shellcheck";  command -v shellcheck  >/dev/null 2>&1 && shellcheck --version | head -2 | tail -1 || echo "✗ missing (required for make lint-shell)"
	@printf '  %-18s ' "actionlint";  command -v actionlint  >/dev/null 2>&1 && actionlint --version | head -1 || echo "⚠ missing (optional, lint-ci skips gracefully)"
	@printf '  %-18s ' "pwsh";        [ -n "$(PWSH)" ] && echo "via: $(PWSH)" || echo "⚠ missing (optional, Pester + PSScriptAnalyzer skip gracefully)"
	@printf '  %-18s ' "gh";          command -v gh          >/dev/null 2>&1 && gh --version | head -1 || echo "⚠ missing (optional, needed by release.yml)"
	@echo "✓ doctor done."
