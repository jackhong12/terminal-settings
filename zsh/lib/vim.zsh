#!/bin/zsh

zinclude "git.zsh"
zinclude "prun.zsh"

# vime: Auto-open changed files {{{
vime () {
  if git_is; then
    # git repo
    root=$(git_root)
    current=$(pwd)
    # porcelain status codes are 2 chars (XY); Y == 'M' means the worktree
    # has local modifications, covering both " M" and "MM" (staged+modified)
    files=$(git status --porcelain | grep -E "^.M" | cut -c4- | while read f; do
      full_path="$root/$f"
      echo -n "$(realpath --relative-to=$current $full_path) "
    done)
    prun vim $files
  else
    # p4 repo
    dir=$(p4_client_root)
    files=$(p4 opened | sed -E "s://pv/icv/([a-z0-9]+\.[_a-z0-9]+/rel|dev)/([^#]*).*:$dir/\2:g" | tr '\n' ' ')
    if [[ ${#files} -gt 0 ]]; then
      prun vim $files
    fi
  fi
}

# }}} vime

# vimp: Open the files in the previous commit {{{

vimp () {
  if git_is; then
    current_dir=$(pwd)
    cd $(git_root)
    files=""
    while IFS= read -r file; do
      files+=" \\"$'\n'
      files+="  $(realpath $file)"
    done < <(git diff-tree --no-commit-id --name-only -r HEAD)
    cd $current_dir
    prun vim $files
  else
    # TODO: p4 repo
  fi
}

# }}} vimp
