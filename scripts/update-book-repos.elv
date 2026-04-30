#!/usr/bin/env elvish
#
# Pass list of files/directories to process as arguments.
# 
# Find repos with manuscript/ in them and do the following:
# - Create/update appropriate workflow file.
# - Set repo secret LEANPUB_API_KEY

use os
use str
use github.com/zzamboni/elvish-modules/1pass
use github.com/zzamboni/elvish-modules/leanpub

# You can set the below by hand if you don't use 1Password
set leanpub:api-key-fn = { str:trim-space (1pass:get-item leanpub &fields=["API key"]) }

fn github-repo-slug {|dir|
  try {
    git -C $dir rev-parse --is-inside-work-tree >/dev/null
  } catch {
    return $nil
  }

  var url = (str:trim-space (git -C $dir remote get-url origin 2>/dev/null))

  if (not (str:contains $url "github.com")) {
    put $nil; return
  }

  # normalize
  var slug = (echo $url | sed -E 's#.*github.com[:/](.+)\.git#\1#')
  put $slug
}

each { |d|
  if (os:is-dir $d/manuscript) {
    var slug = (github-repo-slug $d)
    if (not $slug) {
      echo "#### " $d " (not a GitHub repo, skipping)"
      continue
    }
    echo "#### " $d
    echo "   Copying workflow file"
    mkdir -p $d/.github/workflows
    cp github-workflows/workflow-files/leanpub.yml $d/.github/workflows
    echo "   Setting secret for "$slug
    gh secret set LEANPUB_API_KEY --body (leanpub:api-key) --repo $slug
  }
} $args
