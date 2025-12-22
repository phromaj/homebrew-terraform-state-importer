# Homebrew Tap for terraform-state-importer

This tap provides Homebrew formulae for [terraform-state-importer](https://github.com/Azure/terraform-state-importer).

## Installation

```bash
# Install directly (auto-taps)
brew install phromaj/terraform-state-importer/terraform-state-importer

# Or tap first, then install
brew tap phromaj/terraform-state-importer
brew install terraform-state-importer
```

## Updating

```bash
brew update
brew upgrade terraform-state-importer
```

## Automation

This tap auto-updates the formula from upstream releases using GitHub Actions.

How it works:
- A scheduled workflow (`.github/workflows/auto-update.yml`) runs daily and can be triggered manually.
- The workflow calls `scripts/update_formula.sh` to fetch the latest GitHub release, download the archives, compute SHA256 checksums, and update `Formula/terraform-state-importer.rb`.
- If changes are detected, the workflow commits directly to `main` using the `GITHUB_TOKEN`.

Notes:
- GitHub Actions workflow permissions must allow write access to the repository contents.
- You can run the workflow manually from the Actions tab ("Auto-update formula").

## About

terraform-state-importer is a comprehensive tool for migrating large Azure workloads to Terraform modules.
