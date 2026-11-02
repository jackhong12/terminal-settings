#!/bin/zsh

# is_mac: Check whether this a mac os {{{
is_mac () {
  [[ "$(uname -s)" == "Darwin" ]]
}
# }}} is_mac

# is_linux: Check whether this is a linux os {{{
is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}
# }}} is_linux
