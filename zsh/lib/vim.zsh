#!/bin/zsh

zinclude "git.zsh"
zinclude "prun.zsh"

# vime: Auto-open changed files {{{
vime () {
  if git_is; then
    # git repo
    files=$(git status | grep modified | sed "s/\tmodified:   //g" | tr '\n' ' ')
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
