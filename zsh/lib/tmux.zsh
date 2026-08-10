#!/bin/zsh

zinclude "print.zsh"
zinclude "prun.zsh"

# tmux_is_active: Check whether tmux is active {{{
tmux_is_active () {
  if [[ -n "$TMUX" ]]; then
    return 0
  else
    return 1
  fi
}
# }}} tmux_is_active

# tmux_show_all_sessions: Show all tmux sessions {{{
tmux_show_all_sessions () {
  echo $(tmux ls | sed -r "s|([^ ]*):.*|\1|")
}
# }}} tmux_show_all_sessions

# tmux_is_session_exist: Check whether tmux session exists {{{
tmux_is_session_exist () {
  if [[ "$#" -ne 1 ]]; then
    perror "Usage: tmux_is_session_exist [session_name]\n"
    return 1
  fi

  if ! tmux_is_active; then
    return 1
  fi

  for sn in $(tmux_show_all_sessions); do
    if [[ "$sn" == "$1" ]]; then
      return 0
    fi
  done
  return 1
}

# }}} tmux_is_session_exist

# tmux_attach: Attatch to a tmux session {{{
# Usage:
#   tmux_attach <session_name>

tmux_attach () {
  if [ "$#" -ne 1 ]; then
    perror "Usage: tmux_attach <session_name>\n"
    return 1
  fi

  if ! tmux_is_active; then
    # tmux is not active, create a new session
    tmux new -d -s $1
    tmux attach -t $1
  else
    if ! tmux_is_session_exist $1; then
      # session did not exist, create a new session
      tmux new -d -s $1
    fi
    tmux switch -t $1
  fi
}

_tmux_complete_sessions () {
  local -a sessions
  sessions=($(tmux_show_all_sessions))
  compadd -- $sessions
}

_tmux_attach () {
  _tmux_complete_sessions
}

compdef _tmux_attach tmux_attach 2>/dev/null
# }}} tmux_attach

# tmux_entry: Attach to session entry {{{
tmux_entry () {
  tmux_attach entry
}

# }}} tmux_entry

# tmux_get_current_session_name: Get the current tmux session name {{{
# Usage:
#   $ tmux_get_current_session_name
tmux_get_current_session_name () {
  if ! tmux_is_active; then
    perror "Tmux is not active.\n"
    return 1
  fi

  local current_session=$(tmux display-message -p '#S')
  if [[ -z "$current_session" ]]; then
    perror "No active tmux session found.\n"
    return 1
  fi

  echo $current_session
}
# }}} tmux_get_current_session_name

# tmux_detach: Kill a specific tmux session {{{
# Usage:
#   tmux_detach <session_name>
tmux_detach () {
  if [ "$#" -ne 1 ]; then
    perror "Usage: tmux_detach <session_name>\n"
    return 1
  fi

  if ! tmux_is_session_exist $1; then
    perror "Session '$1' does not exist.\n"
    return 1
  fi

  # If we're inside the session being killed, hop over to entry first,
  # otherwise tmux would kick us out entirely.
  if [[ "$(tmux_get_current_session_name)" == "$1" ]]; then
    tmux_entry
  fi

  tmux kill-session -t $1
}

_tmux_detach () {
  _tmux_complete_sessions
}

compdef _tmux_detach tmux_detach 2>/dev/null
# }}} tmux_detach
