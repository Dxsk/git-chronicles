# Releasing Git Chronicles

This document covers how the downloadable exercise zip is built,
verified, and published, so future maintainers can reason about the
pipeline without reading the workflow YAML.

## Overview

Two release channels coexist:

- **`latest`** (rolling): rebuilt on every push to `main`. The GitHub
  tag `latest` is moved to the new commit, the two release assets are
  replaced in place. URL is stable:
  `https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip`
- **`vX.Y.Z`** (immutable): built when a tag matching `v*` is pushed.
  Each versioned release is permanent and never rewritten.

Both channels publish the same two assets:

- `git-chronicles.zip`
- `git-chronicles.zip.sha256`

## What goes into the zip

The packaging is driven by [`.gitattributes`](../.gitattributes) using
the `export-ignore` attribute. Anything marked `export-ignore` is
excluded from `git archive` and therefore from the final zip. This is
the **single source of truth**: if you add a new dev-only directory
to the repo, add an `export-ignore` line for it.

The packaged zip includes:

- `exercises/` (verifier scripts and exercise assets)
- `lib/` (shared helpers used by the verifiers)
- `README*.md`, `LICENSE-*`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`,
  `SECURITY.md`
- `BUILD_INFO` (injected at build time, see below)

The packaged zip **excludes** the Eleventy site source, the CI
workflows, npm tooling, spell-check configs, and similar developer
infrastructure.

## `BUILD_INFO`

A text file injected at the root of the archive, containing:

```
commit: <full sha>
date:   <commit date in ISO 8601>
tag:    <release label, e.g. 'latest' or 'v1.2.3'>
```

If a learner reports a bug against a downloaded zip, ask them for the
`BUILD_INFO` to identify exactly which commit they have.

## Reproducibility

The build is deterministic: for a given HEAD and version label, two
runs of [`scripts/package-release.sh`](../scripts/package-release.sh)
produce byte-identical zips with the same SHA-256. This relies on:

- `git archive` (stable file ordering and timestamps from the commit)
- `SOURCE_DATE_EPOCH` + `touch -d "@epoch"` normalising mtimes
- `zip -X` stripping extra platform attributes
- Sorted file list piped to `zip`

If you change the script and reproducibility breaks, the bats test
`build is reproducible for the same HEAD and version` will catch it.

## Integrity check

Before publishing, the script performs a round-trip rehash:

1. Hash the staged source tree (pre-zip) recursively with SHA-256.
2. Create the zip, compute its own SHA-256 into the `.sha256` sidecar.
3. Unzip into a temporary verify directory.
4. Hash the verify tree the same way.
5. Fail the build if the two tree hashes differ.

This is the safety net that guarantees the published zip actually
round-trips to the same content.

## Guardrails

Two env-configurable thresholds catch silent packaging regressions:

- `PACKAGE_MIN_FILES` (default: 10): minimum file count in the zip.
  Protects against a broken exclude rule that would empty the archive.
- `PACKAGE_MAX_BYTES` (default: 20 MB): maximum zip size. Protects
  against an accidental include of binaries, media, or dev trees.

If either guard fails, the build exits non-zero with an explicit
error message and the release is **not** published.

## Building locally

From the repo root:

```bash
./scripts/package-release.sh
```

Outputs land in `build/`:

- `build/git-chronicles.zip`
- `build/git-chronicles.zip.sha256`

Env overrides for experimentation:

```bash
PACKAGE_VERSION=v1.2.3-rc1 ./scripts/package-release.sh
PACKAGE_OUTPUT_DIR=/tmp/release ./scripts/package-release.sh
```

## Running the packaging tests

```bash
bats tests/packaging/package-release.bats
```

Seven scenarios cover: script success, sha256 sidecar integrity,
`BUILD_INFO` injection, custom version labels, reproducibility, and
both guardrails.

## Cutting a versioned release

```bash
git tag v1.0.0
git push origin v1.0.0
```

The `Package Release` workflow picks up the tag, builds the zip with
`PACKAGE_VERSION=v1.0.0`, and publishes an immutable GitHub release
named `v1.0.0`. The rolling `latest` release is untouched.

## Verifying a downloaded zip

Users (and you) can verify the integrity of any downloaded zip:

```bash
curl -LO https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip
curl -LO https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip.sha256
sha256sum -c git-chronicles.zip.sha256
```

The command prints `git-chronicles.zip: OK` on success.

## Supply chain notes

- All GitHub Actions in `.github/workflows/` are pinned by commit SHA,
  with a trailing comment noting the resolved version.
- `dependabot.yml` opens monthly PRs to keep those SHAs fresh.
- Workflow changes require a review before merging (keep in mind if
  you add a CODEOWNERS entry later for `.github/workflows/`).
