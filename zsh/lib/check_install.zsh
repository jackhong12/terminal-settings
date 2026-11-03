#!/bin/zsh


# check_install: Check whether the binary exists. If not, install it by apt-get {{{

if [[ -v __INCLUDE_ZLIB_ZSH__ ]]; then
  zinclude "prun.zsh"
  zinclude "os.zsh"

  check_install () {
    for exe in "$@"; do
      if ! command -v $exe &> /dev/null; then
        if is_mac; then
          prun brew install $exe
        elif is_linux; then
          prun sudo apt-get install -y $exe
        else
          echo "Unsupported OS"
        fi
      fi
    done
  }

else
  __prun () {
    cmd="$@"
    printf "\033[0;32m"
    printf "$ $cmd\n"
    printf "\033[0m"
    eval "$cmd"
  }

  is_mac () {
    [[ "$(uname)" == "Darwin" ]]
  }

  is_linux () {
    [[ "$(uname)" == "Linux" ]]
  }

  # Self-contaned version
  check_install () {
    for exe in "$@"; do
      if ! command -v $exe &> /dev/null; then
        if is_mac; then
          __prun brew install $exe
        elif is_linux; then
          __prun sudo apt-get install -y $exe
        else
          echo "Unsupported OS"
        fi
      fi
    done
  }
fi

#}}} check_install
