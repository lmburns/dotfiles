# Desc: tmux switch session
function tmux::switch() {
  [[ ! $TMUX ]] && return 1 # Not in tmux session
  local preview curr choice
  preview='<<< {} awk "{print \$2}" | xargs tmux list-windows -t | sed "s/\[.*\]//g" | column -t | sed "s/  \(\S\)/ \1/g"'
  curr=$(tmux display-message -p "#S")
  choice=$(tmux ls -F "#{session_name}" | grep -v $curr | nl -w2 -s' ' \
      | fzf-tmux --no-sort \
                 --cycle \
                 --exact  \
                 --select-1 \
                 --exit-0 \
                 --height=14 \
                 --header="  * $curr" \
                 --bind 'alt-t:down' \
                 --preview="$preview" \
                 --preview-window=right:60%)
  [[ -n "$choice" ]] && \
    tmux switch-client -t $(awk '{print $2}' <<<"$choice") 2>/dev/null
}

# Desc: tmux attach session
function tmux::attach() {
  [[ $TMUX ]] && return 1 # Already in tmux session
  local preview choice
  preview='<<< {} awk "{print \$2}" | xargs tmux list-windows -t | sed "s/\[.*\]//g" | column -t | sed "s/  \(\S\)/ \1/g"'
  choice=$(tmux ls -F "#{session_name}" | nl -w2 -s' ' \
      | fzf-tmux --no-sort \
                 --cycle \
                 --exact  \
                 --select-1 \
                 --exit-0 \
                 --height=14 \
                 --header="  * $curr" \
                 --bind 'alt-t:down' \
                 --preview="$preview" \
                 --preview-window=right:60%)
  [[ -n "$choice" ]] && \
    tmux attach-session -t $(awk '{print $2}' <<<"$choice") 2>/dev/null
}

# Desc: tmux select window
function tmux::select-window() {
  [[ ! $TMUX ]] && return 1
  local curr choice
  curr=$(tmux display-message -p "#W")
  choice=$(tmux list-windows -F "#I #W #F" | grep -v '*' | awk '{printf "%2d %s\n", $1, $2}' \
      | fzf-tmux --no-sort \
                 --cycle \
                 --exact  \
                 --select-1 \
                 --exit-0 \
                 --height=10 \
                 --header="  * $curr" \
                 --bind='alt-w:down')
  [[ -n "$choice" ]] && \
    tmux select-window -t $(awk '{print $2}' <<<"$choice") 2>/dev/null
  (($+WIDGET)) && zle redisplay
  # zle redisplay 2>/dev/null || true
}

# Desc: tmux attach or create target session
function tmux::attach-create() {
  if (( ! $# )) {
    if (( $+TMUX )) {
      tmux::switch
    } else {
      if tmux list-sessions &>/dev/null; then
          tmux-attach
      else
          tmux new-session -A -s "misc"
      fi
    }
  } else {
    if (( $+TMUX )) {
      if ! tmux has-session -t "$1" 2>/dev/null; then
        tmux new-session -d -s "$1"
      fi
      tmux switch-client -t "$1"
    } else {
      tmux new-session -A -s "$1"
    }
  }
  (($+WIDGET)) && zle redisplay
}

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:tw=100
