#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: history                                                      #
#      @desc: Functions dealing with zsh history                           #
#===========================================================================

autoload -U add-zsh-hook

# Shorten command length
function max_history_len() {
  if (( $#1 > 240 )) {
    return 2
  }
  return 0
}

# Function that is ran on each command
function zshaddhistory() {
  emulate -L zsh
  # whence ${${(z)1}[1]} >| /dev/null || return 1 # doesn't add setting arrays
  # [[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
  local -r line=${1%%$'\n'}
  local -r cmd=${line%% *}
  # [[ ${#line} -lt 5 ]] && return 1
  (( ! $+histignore[(r)${cmd}] ))
}

add-zsh-hook zshaddhistory max_history_len

# Based on directory history
function _zsh_autosuggest_strategy_dir_history() {
  emulate -L zsh -o extended_glob
  if $_per_directory_history_is_global && [[ -r "$_per_directory_history_path" ]]; then
    local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
    local pattern="$prefix*"
    if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
      pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
    fi
    [[ "${dir_history[(r)$pattern]}" != "$prefix" ]] && \
      typeset -g suggestion="${dir_history[(r)$pattern]}"
  fi
}

# Same as above, but not directory specific
function _zsh_autosuggest_strategy_custom_history() {
  emulate -L zsh -o extended_glob
  local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
  local pattern="$prefix*"
  if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
    pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
  fi
  [[ "${history[(r)$pattern]}" != "$prefix" ]] && \
    typeset -g suggestion="${history[(r)$pattern]}"
}

# Histdb is good, though, the above allows for toggling on and off

# Return the latest used command in the current directory
# Else, find most recent command
function _zsh_autosuggest_strategy_histdb_top_here() {
    emulate -L zsh
    (( $+functions[_histdb_query] && $+builtins[zsqlite_exec] )) || return
    # (( $+functions[_histdb_query] )) || return
    # _histdb_init
    local last_cmd="$(sql_escape ${history[$((HISTCMD-1))]})"
    local cmd="$(sql_escape $1)"
    local pwd="$(sql_escape $PWD)"
#     local reply=$(zsqlite_exec _HISTDB "
# SELECT argv FROM (
#   SELECT c1.argv, p1.dir, h1.session, h1.start_time, 1 AS priority
#   FROM history h1, history h2
#     LEFT JOIN commands c1 ON h1.command_id = c1.ROWID
#     LEFT JOIN commands c2 ON h2.command_id = c2.ROWID
#     LEFT JOIN places p1   ON h1.place_id = p1.ROWID
#   WHERE h1.ROWID = h2.ROWID + 1
#     AND c1.argv LIKE '$cmd%'
#     AND c2.argv = '$last_cmd'
#     -- AND h1.exit_status = 0
#     UNION
#   SELECT c1.argv, p1.dir, h1.session, h1.start_time, 0 AS priority
#   FROM history h1
#     LEFT JOIN commands c1 ON h1.command_id = c1.ROWID
#     LEFT JOIN places p1   ON h1.place_id = p1.ROWID
#   WHERE c1.argv LIKE '$cmd%'
# )
# ORDER BY dir != '$pwd', start_time, priority DESC, session != $HISTDB_SESSION DESC
# LIMIT 1
# ")
    # local reply=$(_histdb_query "
    local reply=$(zsqlite_exec _HISTDB "
SELECT commands.argv
FROM   history
  LEFT JOIN commands
    ON history.command_id = commands.rowid
  LEFT JOIN places
    ON history.place_id = places.rowid
WHERE    commands.argv LIKE '$cmd%'
        AND commands.argv NOT LIKE 'o %'
        AND commands.argv NOT LIKE 'cd %'
-- AND history.exit_status = 0
-- GROUP BY commands.argv, places.dir
ORDER BY places.dir != '$pwd', history.start_time DESC
LIMIT 1
")
    typeset -g suggestion=$reply

# (( $+functions[_histdb_query] )) || return
#   typeset -g suggestion=$(_histdb_query "$query")
}
