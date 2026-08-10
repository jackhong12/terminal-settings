#!/bin/zsh

zinclude "tmux.zsh"
zinclude "print.zsh"

typeset -A tpvars
tpvars[root]=~/projects
tpvars[info_file]=.info
tpvars[trash_dir]=~/.tprojects_trash

# tproject_init: Initialize a new project {{{
# Usage:
#   $ tproject_init <project_name> [description]
tproject_init () {
  if [ "$#" -lt 1 ]; then
    perror "Usage: tproject_init <project_name>\n"
    return 1
  fi

  local project_name=$1
  local project_dir=$tpvars[root]/$project_name
  if [[ ! -d $project_dir ]]; then
    # create directories
    prun mkdir -p $project_dir
    prun tmux new -d -s $project_name
    tmux send-keys -t $project_name "cd $project_dir && clear" ENTER
  fi

  if [ "$#" -eq 2 ]; then
    echo "$2" > $project_dir/$tpvars[info_file]
  fi

  # attach to the new project session
  tmux_attach $project_name
}

# }}} tproject_init

# tproject_load_all: Load all projects {{{
# Usage:
#   $ tproject_load_all

tproject_load_all () {
  if [[ ! -d $tpvars[root] ]]; then
    perror "Project root directory does not exist: ${tpvars[root]}\n"
    return 1
  fi

  prun tmux new -d -s entry

  for project in $(ls $tpvars[root]); do
    if [[ -d "$tpvars[root]/$project" ]]; then
      if ! tmux_is_session_exist $project; then
        # create a new session for the project
        prun tmux new -d -s $project
        tmux send-keys -t $project "cd $tpvars[root]/$project && clear" ENTER
      fi
    fi
  done

  # attach to the entry session
  tmux_entry
}

# }}} tproject_load_all

# tproject_close_all: Close all projects {{{
# Usage:
#   $ tproject_close_all

tproject_close_all () {
  if ! tmux_is_active; then
    perror "Tmux is not active.\n"
    return 1
  fi
  prun tmux kill-server
}

# }}} tproject_close_all

# tproject_set_var: Set tproject variable {{{
# Usage:
#   $ tproject_set_var <key> <value>
tproject_set_var () {
  if [ "$#" -ne 2 ]; then
    perror "Usage: tproject_set_var <key> <value>\n"
    return 1
  fi

  local key=$1
  local value=$2

  if [[ -z "$key" || -z "$value" ]]; then
    perror "Key and value cannot be empty.\n"
    return 1
  fi

  # Only accept keys: root, info_file.
  if [[ "$key" != "root" &&
        "$key" != "info_file" ]]; then
    perror "Invalid key: $key\n".
    return 1
  fi

  tpvars[$key]=$value
  pinfo "Set tproject variable: $key = $value\n"
}

# }}} tproject_set_var

# tproject_show_vars: Show tproject variables {{{
# Usage:
#   $ tproject_show_vars

tproject_show_vars () {
  if [[ ${#tpvars[@]} -eq 0 ]]; then
    perror "No tproject variables set.\n"
    return 1
  fi

  pinfo "TProject Variables:\n"
  for key in "${(@k)tpvars}"; do
    echo "\t$key: ${tpvars[$key]}"
  done
}

# }}} tproject_show_vars

# tproject_attach: Attach to a project {{{
# Usage:
#   $ tproject_attach <project_name>

tproject_attach () {
  if [ "$#" -ne 1 ]; then
    perror "Usage: tproject_attach <project_name>\n"
    return 1
  fi

  local project_name=$1
  local project_dir=$tpvars[root]/$project_name

  if [[ ! -d $project_dir ]]; then
    prun tproject_init $@
    return 0
  fi

  if ! tmux_is_session_exist $project_name; then
    # create a new session for the project
    prun tmux new -d -s $project_name
    tmux send-keys -t $project_name "cd $project_dir && clear" ENTER
  fi

  # attach to the project session
  tmux_attach $project_name
}

_tproject_complete_infos () {
  local -a args
  for project in $(ls $tpvars[root]); do
    project_dir=$tpvars[root]/$project
    info_path=$project_dir/$tpvars[info_file]
    if [[ -d $project_dir ]]; then
      if [[ -f $info_path ]]; then
        args+=("${project}: $(cat $info_path)")
      else
        args+=("${project}")
      fi
    fi
  done
  _describe "project names" args
}

_tproject_attach () {
  _tproject_complete_infos
}

compdef _tproject_attach tproject_attach

# }}} tproject_attach

# tproject_pwd: Get the path of the current project {{{
# Usage:
#   $ tproject_pwd
tproject_pwd () {
  if ! tmux_is_active; then
    perror "Tmux is not active.\n"
    return 1
  fi
  local current_session=$(tmux_get_current_session_name)
  if [[ -z "$current_session" ]]; then
    perror "No active tmux session found.\n"
    return 1
  fi

  echo "$tpvars[root]/$current_session"
}

# }}} tproject_pwd

# tproject_cd: Change directory to a project {{{
# Usage:
#   - Move to the current project directory
#     $ tproject_cd
#   - Move to a folder in the current project
#     $ tproject_cd <folder_name>

tproject_cd () {
  if ! tmux_is_active; then
    perror "Tmux is not active.\n"
    return 1
  fi

  local current_session=$(tmux_get_current_session_name)
  if [[ -z "$current_session" ]]; then
    perror "No active tmux session found.\n"
    return 1
  fi

  local project_dir="$tpvars[root]/$current_session"

  if [[ ! -d $project_dir ]]; then
    perror "Project directory does not exist: $project_dir\n"
    return 1
  fi

  if [[ "$#" -eq 0 ]]; then
    cd $project_dir
    return 0
  elif [[ "$#" -eq 1 ]]; then
    cd "$project_dir/$1"
    return 0
  else
    perror "Usage: tproject_cd [folder_name]\n"
    return 1
  fi
}

# }}} tproject_cd

# tproject_delete: Move a project to the trash directory {{{
# Usage:
#   $ tproject_delete <project_name>
tproject_delete () {
  if [ "$#" -ne 1 ]; then
    perror "Usage: tproject_delete <project_name>\n"
    return 1
  fi

  local project_name=$1
  local project_dir=$tpvars[root]/$project_name

  if [[ ! -d $project_dir ]]; then
    perror "Project directory does not exist: $project_dir\n"
    return 1
  fi

  mkdir -p $tpvars[trash_dir]

  # Move the project directory to the trash directory
  prun mv $project_dir $tpvars[trash_dir]/$project_name

  # Close the tmux session if it exists
  if tmux_is_session_exist $project_name; then
    prun tmux kill-session -t $project_name
  fi
}

_tproject_delete () {
  _tproject_complete_infos
}

compdef _tproject_delete tproject_delete

# }}} tproject_delete

# tproject_clean_trash: Remove projects older than 30 days from the trash directory {{{
# Usage:
#   $ tproject_clean_trash
tproject_clean_trash () {
  if [[ ! -d $tpvars[trash_dir] ]]; then
    perror "Trash directory does not exist: ${tpvars[trash_dir]}\n"
    return 1
  fi

  local trash_files=($(find $tpvars[trash_dir]/* -maxdepth 0 -type d -mtime +30))
  if [[ ${#trash_files[@]} -eq 0 ]]; then
    return 0
  fi

  pinfo "Trashed Projects:\n"
  for file in $trash_files; do
    echo "\t$file"
  done
}

# }}} tproject_clean_trash
