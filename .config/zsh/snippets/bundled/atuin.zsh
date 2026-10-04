autoload -U add-zsh-hook

zmodload zsh/datetime 2>/dev/null

typeset -g _atuin_histdb
export ATUIN_SESSION=$(atuin uuid)
export ATUIN_HISTORY="atuin history list"
ATUIN_HISTORY_ID=""

_atuin_histdb_init() {
    if (( $+_atuin_histdb )); then
        zsqlite_open -r _atuin_histdb ~/.local/share/atuin/history.db
    fi
}

# Return the latest used command in the current directory
# Else, find most recent command
function _zsh_autosuggest_strategy_atuin() {
    emulate -L zsh
    _atuin_histdb_init

# SELECT commands.argv
# FROM   history
#   LEFT JOIN commands
#     ON history.command_id = commands.rowid
#   LEFT JOIN places
#     ON history.place_id = places.rowid
# WHERE    commands.argv LIKE '$cmd%'
#         AND commands.argv NOT LIKE 'o %'
#         AND commands.argv NOT LIKE 'cd %'
# -- AND history.exit_status = 0
# -- GROUP BY commands.argv, places.dir
# ORDER BY places.dir != '$pwd', history.start_time DESC
# LIMIT 1

    local reply=$(zsqlite_exec _atuin_histdb "
SELECT command FROM (
    SELECT h1.*
    FROM history h1, history h2
    WHERE h1.ROWID = h2.ROWID + 1
        AND h1.session = h2.session
        -- AND h2.exit = 0
        AND h1.command LIKE ?1
        AND h2.command = ?2
        AND h1.cwd = ?3
    ORDER BY timestamp DESC
    LIMIT 1
)
UNION ALL
SELECT command FROM (
    SELECT * FROM history WHERE cwd = ?3 AND command LIKE ?1 ORDER BY timestamp DESC LIMIT 1
)
UNION ALL
SELECT command FROM (
    SELECT * FROM history WHERE command LIKE ?1 ORDER BY timestamp DESC LIMIT 1
)
LIMIT 1
" ${1}% ${history[$((HISTCMD-1))]} $PWD )
    typeset -g suggestion=$reply
}

_atuin_preexec(){
  local id
  id=$(atuin history start -- "$1")
  export ATUIN_HISTORY_ID="$id"
  __atuin_preexec_time=${EPOCHREALTIME-}
}

_atuin_precmd(){
  local EXIT="$?" __atuin_precmd_time=${EPOCHREALTIME-}

  [[ -z "${ATUIN_HISTORY_ID:-}" ]] && return

  local duration=""
  if [[ -n $__atuin_preexec_time && -n $__atuin_precmd_time ]]; then
    printf -v duration %.0f $(((__atuin_precmd_time - __atuin_preexec_time) * 1000000000))
  fi

  (ATUIN_LOG=error atuin history end --exit $EXIT ${duration:+--duration=$duration} -- $ATUIN_HISTORY_ID &) >/dev/null 2>&1
  export ATUIN_HISTORY_ID=""
}

__atuin_search_cmd() {
  local -a search_args=("$@")
  ATUIN_SHELL=zsh ATUIN_LOG=error ATUIN_QUERY=$BUFFER atuin search "${search_args[@]}" -i 3>&1 1>&2 2>&3 3>&-
}

_atuin_search(){
  emulate -L zsh

  _atuin_histdb_init

  local query="
SELECT DISTINCT command
FROM history
WHERE command LIKE ?
ORDER BY cwd = ? DESC, timestamp DESC
"

  # local output=$(zsqlite_exec -q _atuin_histdb $query ${LBUFFER}% $PWD | ftb-tmux-popup --tiebreak=index --prompt="cmd> " ${LBUFFER:+-q$LBUFFER})
  #
  # if [[ $output != "" ]]; then
  #   BUFFER=$(echo $output)
  #   CURSOR=$#BUFFER
  # fi

  zle -I

  # swap stderr and stdout, so that the tui stuff works
  local output __atuin_status
  output=$(__atuin_search_cmd $*)
  __atuin_status=$?

  zle reset-prompt
  # re-enable bracketed paste
  echo -n ${zle_bracketed_paste[1]} >/dev/tty

  if (( __atuin_status != 0 )); then
    [[ -n $output ]] && print -r -- "$output" >/dev/tty
    return $__atuin_status
  fi

  if [[ -n $output ]]; then
    RBUFFER=""
    LBUFFER=$output

    if [[ $LBUFFER == __atuin_accept__:* ]]
    then
      LBUFFER=${LBUFFER#__atuin_accept__:}
      zle accept-line
    fi
  fi
}

add-zsh-hook preexec _atuin_preexec
add-zsh-hook precmd _atuin_precmd

zle -N atuin-search _atuin_search
zle -N _atuin_search_widget _atuin_search

bindkey -M viins '^r' atuin-search

# vim: ft=zsh:et:sts=2:sw=0:ts=2:fdm=marker:fmr={{{,}}}:
