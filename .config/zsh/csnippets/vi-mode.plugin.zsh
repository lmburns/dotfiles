declare -g VI_MODE_RESET_PROMPT_ON_MODE_CHANGE # reset on each change
declare -g VI_MODE_SET_CURSOR # change cursor on mode change
declare -g VI_KEYMAP=main

function _vi-mode-set-cursor-shape-for-keymap() {
  [[ "$VI_MODE_SET_CURSOR" = true ]] || return

  integer _shape=0
  case "${1:-${VI_KEYMAP:-main}}" in
    main)    _shape=5 ;; # vi insert: line
    viins)   _shape=5 ;; # vi insert: line
    isearch) _shape=5 ;; # inc search: line
    command) _shape=5 ;; # read a command name
    vicmd)   _shape=0 ;; # vi cmd: block
    visual)  _shape=0 ;; # vi visual mode: block
    viopp)   _shape=0 ;; # vi operation pending: blinking block
    *)       _shape=0 ;;
  esac

  # if [[ -z $TMUX ]] {
    printf $'\e[%d q' "${_shape}"
  # } else {
    # Is \e\e needed?
    # printf $'\ePtmux;\e\e\e[%d q\e\\' "${_shape}"
  # }
}

# updates editor information when the keymap changes
function zle-keymap-select() {
  # update keymap variable for the prompt
  declare -g VI_KEYMAP=$KEYMAP

  if [[ "${VI_MODE_RESET_PROMPT_ON_MODE_CHANGE:-}" = true ]]; then
    zle reset-prompt
    zle -R
  fi
  _vi-mode-set-cursor-shape-for-keymap "${VI_KEYMAP}"
}
zle -N zle-keymap-select

function zle-line-init() {
  local prev_vi_keymap
  prev_vi_keymap="${VI_KEYMAP:-}"
  declare -g VI_KEYMAP=main
  [[ $prev_vi_keymap != 'main' && ${VI_MODE_RESET_PROMPT_ON_MODE_CHANGE:-} = true ]] && \
    zle reset-prompt

  (( ! ${+terminfo[smkx]} )) || echoti smkx
  _vi-mode-set-cursor-shape-for-keymap "${VI_KEYMAP}"
}
zle -N zle-line-init

function zle-line-finish() {
  declare -g VI_KEYMAP=main
  (( ! ${+terminfo[rmkx]} )) || echoti rmkx
  _vi-mode-set-cursor-shape-for-keymap default
}
zle -N zle-line-finish

bindkey -v

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
# bindkey '^P' up-history
# bindkey '^N' down-history

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r and ctrl-s to search the history
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

function wrap_clipboard_widgets() {
  local verb="$1"; shift
  local widget
  local wrapped_name

  for widget in "$@"; do
    wrapped_name="_zsh-vi-${verb}-${widget}"
    if [ "${verb}" = copy ]; then
      eval "
        function ${wrapped_name}() {
          zle .${widget}
          printf %s \"\${CUTBUFFER}\" | ccopy 2>/dev/null || true
        }
      "
    else
      eval "
        function ${wrapped_name}() {
          CUTBUFFER=\"\$(cpaste 2>/dev/null || echo \$CUTBUFFER)\"
          zle .${widget}
        }
      "
    fi
    zle -N "${widget}" "${wrapped_name}"
  done
}

wrap_clipboard_widgets copy vi-yank{,-eol} vi-backward-kill-word vi-change-whole-line
wrap_clipboard_widgets paste vi-put-{before,after}
unfunction wrap_clipboard_widgets

# if mode indicator wasn't setup by theme, define default
if [[ -z "$MODE_INDICATOR" ]]; then
  MODE_INDICATOR='%B%F{red}<%b<<%f'
fi

function vi_mode_prompt_info() {
  # If we're using the prompt to display mode info, and we haven't explicitly
  # disabled "reset prompt on mode change", then set it here.
  #
  # We do that here instead of the `if` statement below because the user may
  # set RPS1/RPROMPT to something else in their custom config.
  : "${VI_MODE_RESET_PROMPT_ON_MODE_CHANGE:=true}"

  echo "${${VI_KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# define right prompt, if it wasn't defined by a theme
if [[ -z "$RPS1" && -z "$RPROMPT" ]]; then
  RPS1='$(vi_mode_prompt_info)'
fi
