# github-workflows

Shared GitHub Actions workflow and helper script for Leanpub book repositories.

## What this repo does

This repository centralizes the automation used by book repos that are published
from GitHub to Leanpub.

It contains:

- A reusable GitHub Actions workflow at [.github/workflows/leanpub.yml](.github/workflows/leanpub.yml) that performs Leanpub preview and publish actions.
- A template workflow at [workflow-files/leanpub.yml](workflow-files/leanpub.yml) that book repos copy into their own `.github/workflows/` directory to call the main workflow.
- A setup script at [scripts/update-book-repos.elv](scripts/update-book-repos.elv) that updates multiple book repos in one pass. This script is written in [Elvish Shell](https://elv.sh) and uses some modules from [zzamboni/elvish-modules](https://github.com/zzamboni/elvish-modules).

## Workflow behavior

Book repositories use the template workflow, which delegates to the reusable
workflow in this repo:

```yaml
jobs:
  leanpub:
    uses: zzamboni/github-workflows/.github/workflows/leanpub.yml@main
```

The reusable workflow uses the repository name as the Leanpub book slug and
expects a `LEANPUB_API_KEY` secret to be present.

It reacts to these Git refs:

- Push to `main` or `master`: build a subset preview on Leanpub.
- Tag starting with `preview`: build a full preview on Leanpub.
- Tag starting with `silent-publish`: publish without emailing readers.
- Tag starting with `publish`: publish and email readers.

For `publish*` tags, if the tag is an annotated tag, the annotation text is
sent to Leanpub as release notes. If the tag is lightweight, the workflow
publishes without release notes.

## Updating book repos

The Elvish helper script is meant to be run against local checkouts of book
repositories. For each argument passed in, it checks whether the directory
contains a `manuscript/` subdirectory. If it does, the script:

- Verifies the directory is a GitHub-backed Git repository.
- Copies [workflow-files/leanpub.yml](workflow-files/leanpub.yml) to `.github/workflows/leanpub.yml` in that repo.
- Sets the `LEANPUB_API_KEY` GitHub Actions secret for that repo with `gh secret set`.

Example:

```bash
elvish scripts/update-book-repos.elv ~/src/book-one ~/src/book-two
```

## Prerequisites

To use the helper script, the local environment needs:

- `elvish`
- `gh` authenticated with permission to manage repository secrets
- The `github.com/zzamboni/elvish-modules/1pass` and `github.com/zzamboni/elvish-modules/leanpub` Elvish modules
- A 1Password item named `leanpub` with an `API key` field (otherwise modify the script to specify the API key to use)

## Notes

- The helper script only updates repos that contain a `manuscript/` directory.
- The template workflow is pinned to `@main` of this repository, so changes to
  the reusable workflow affect consuming repos without needing to update their
  copied template file.
- The script currently copies from `github-workflows/workflow-files/leanpub.yml`,
  so it assumes this repository is available locally at that relative path when
  the script is run.
