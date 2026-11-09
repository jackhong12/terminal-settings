#!/bin/zsh

# relpath_to: Print path $1 relative to directory $2 {{{
# Pure zsh, so it works with BSD realpath (macOS), which lacks --relative-to.
#   $ relpath_to /a/b/c.txt /a/d   # => ../b/c.txt
relpath_to () {
  local -a target base parts
  local i j
  target=(${(s:/:)1})
  base=(${(s:/:)2})

  i=1
  while (( i <= $#target && i <= $#base )) && [[ $target[i] == $base[i] ]]; do
    (( i++ ))
  done

  for (( j = i; j <= $#base; j++ )); do
    parts+=(..)
  done
  for (( j = i; j <= $#target; j++ )); do
    parts+=($target[j])
  done

  print -r -- "${(j:/:)parts}"
}

# }}} relpath_to
