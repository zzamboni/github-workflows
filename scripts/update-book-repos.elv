#!/usr/bin/env elvish
#
# Pass list of files/directories to process as arguments.
# 
# Find repos with manuscript/ in them and do the following:
# - Create/update appropriate workflow file.
# - Set repo secret LEANPUB_API_KEY

use leanpub
use os

each { |d|
  if (os:is-dir $d/manuscript) {
    echo "#### " $d
    echo "   Copying workflow file"
    mkdir -p $d/.github/workflows
    cp github-workflows/workflow-files/leanpub.yml $d/.github/workflows
    echo "   Setting secret"
    gh secret set LEANPUB_API_KEY --body (leanpub:api-key) --repo zzamboni/$d
  }
} $args
