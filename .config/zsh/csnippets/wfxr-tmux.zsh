##################################################################################
# OTHER
##################################################################################

# remove broken symbolics
function wfxr::rm-broken-links() {
    local ls links
    (( $+commands[exa] )) && ls=exa || ls=ls
    IFS=$'\n' links=(`eval "find $1 -xtype l"`)
    [[ -z $links ]] && return
    $ls -l --color=always ${links[@]}
    echo -n "Remove? [y/N]: "
    read -q && rm -- ${links[@]}
}

# function rm::broken() {
#   local ls; local -a links
#   (( $+commands[exa] )) && ls=exa || ls=ls
#   links=( ${(@f)"$(fd -tl)"})
#   [[ -z $links ]] && return
#   $ls -l --color=always ${links[@]}
#   echo -n "Remove? [y/N]: "
#   read -q && rm -- ${links[@]}
# }

function rm-broken-links-all() { wfxr::rm-broken-links               }
function rm-broken-links()     { wfxr::rm-broken-links '-maxdepth 1' }

function lsdelete() { lsof -n | rg -i --color=always deleted }

function ansi_strip() { sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" "$@"; }

# Perl rename
function backup-t()  { /usr/bin/rename -n 's/^(.*)$/$1.bak/g' $@ }
function backup()    { /usr/bin/rename    's/^(.*)$/$1.bak/g' $@ }
function restore-t() { /usr/bin/rename -n 's/^(.*).bak$/$1/g' $@ }
function restore()   { /usr/bin/rename    's/^(.*).bak$/$1/g' $@ }

# function bak()  { renamer '$=.bak' "$@"; }
# function rbak() { renamer '.bak$=' "$@"; }

function vcurl() {
    local TMPFILE="$(mktemp -t --suffix=.json)"
    trap "\\rm -f '$TMPFILE'" EXIT INT TERM HUP
    nvim "$TMPFILE" >/dev/tty
    curl ${(@f)"$(<$TMPFILE)"}
}

function kcurl() {
    local BUFFER="/tmp/curl-body-buffer.json"
    touch "$BUFFER" && nvim "$BUFFER" >/dev/tty
    curl "$@" < "$BUFFER"
}

# Open git repo in browser
function grepo() {
    [[ "$#" -ne 0 ]] && return $(handlr open "https://github.com/${(j:/:)@}")
    local url
    url=$(git remote get-url origin) || return $?
    [[ "$url" =~ '^git@' ]] && url=$(echo "$url" | sed -e 's#:#/#' -e 's#git@#https://#')
    command handlr open "$url"
}

# Dump zsh hash
function dump_map() {
    local cmd="
        for k in \"\${(@k)$1}\"; do
            echo $2 \"\$k => \$$1[\$k]\"
        done
    "
    eval "$cmd"
}

##################################################################################
# UNICODE
##################################################################################

function __unicode_translate() {
  builtin setopt extendedglob
  local CODE=$BUFFER[-4,-1]
  [[ ! ${(U)CODE} = [0-9A-F](#c4) ]] && return
  CHAR=`echo -e "\\u$CODE"`
  BUFFER=$BUFFER[1,-5]$CHAR
  CURSOR=$#BUFFER
  zle redisplay
}

function unicode-map() {
    ruby \
      -e '0x100.upto(0xFFFF) do |i| puts "%04X%8d%6s" % [i, i, i.chr("UTF-8")] rescue true end' \
    | fzf -m
}

##################################################################################
# FZF
##################################################################################

FZF_ALT_E_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_E_COMMAND
FZF_ALT_E_OPTS="
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind 'alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--preview-window default:right:60%
"
export FZF_ALT_E_OPTS

# ALT-E - Edit selected file
function wfxr::fzf-file-edit-widget() {
    setopt localoptions pipefail 2> /dev/null
    local files
    files=$(eval "$FZF_ALT_E_COMMAND" |
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_E_OPTS" fzf -m |
        sed 's/^\s\+.\s//')
    local ret=$?

    [[ $ret -eq 0 ]] && echo $files | xargs sh -c "$EDITOR \$@ </dev/tty" $EDITOR

    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle     -N    wfxr::fzf-file-edit-widget
# bindkey '\ee' wfxr::fzf-file-edit-widget

function fe() {
  local -a files sel
  files=$(command fd -Hi -tf -d2)
  sel=("$(
    print -rl -- "$files[@]" | \
    fzf --query="$1" \
      --multi \
      --select-1 \
      --exit-0 \
      --bind=ctrl-x:toggle-sort \
      --preview-window=':nohidden,right:65%:wrap' \
      --preview='([[ -f {} ]] && (bat --style=numbers --color=always {})) || ([[ -d {} ]] && (exa -TL 3 --color=always --icons {} | less)) || echo {} 2> /dev/null | head -200'
    )"
  )
  [[ -n "$sel" ]] && ${EDITOR:-vim} "${sel[@]}" || zle redisplay
}

##################################################################################
# TMUX
##################################################################################

# Tmux switch session
function wfxr::tmux-switch() {
    [[ ! $TMUX ]] && return 1 # Not in tmux session
    local preview curr choice &&
        preview='<<< {} awk "{print \$2}" | xargs tmux list-windows -t | sed "s/\[.*\]//g" | column -t | sed "s/  \(\S\)/ \1/g"' &&
        curr=$(tmux display-message -p "#S") &&
        choice=$(tmux ls -F "#{session_name}" | grep -v $curr | nl -w2 -s' ' \
            | fzf-tmux +s -e -1 -0 --height=14 --header="  * $curr" \
                              --bind 'alt-t:down' --cycle \
                              --preview="$preview" \
                              --preview-window=right:60%) &&
        tmux switch-client -t $(awk '{print $2}' <<<"$choice") 2>/dev/null
}
# Tmux attach session
function wfxr::tmux-attach() {
    [[ $TMUX ]] && return 1 # Already in tmux session
    local preview choice &&
        preview='<<< {} awk "{print \$2}" | xargs tmux list-windows -t | sed "s/\[.*\]//g" | column -t | sed "s/  \(\S\)/ \1/g"' &&
        choice=$(tmux ls -F "#{session_name}" | nl -w2 -s' ' \
            | fzf +s -e -1 -0 --height=14 \
                              --bind 'alt-t:down' --cycle \
                              --preview="$preview" \
                              --preview-window=right:60%) &&
        tmux attach-session -t $(awk '{print $2}' <<<"$choice") 2>/dev/null
}
# Tmux select window
function wfxr::tmux-select-window() {
    [[ ! $TMUX ]] && return 1
    local curr choice &&
        curr=$(tmux display-message -p "#W") &&
        choice=$(tmux list-windows -F "#I #W #F" | grep -v '*' | awk '{printf "%2d %s\n", $1, $2}' \
        | fzf-tmux +s -e -1 -0 --height=10 --header=" * $curr"\
                          --bind 'alt-w:down' --cycle) &&
        tmux select-window -t $(awk '{print $2}' <<<"$choice") 2>/dev/null
        zle redisplay 2>/dev/null || true
}
# Tmux attach or create target session
function tmt() {
    if [[ $# -eq 0 ]]; then
        if [[ $TMUX ]]; then
            wfxr::tmux-switch
        else
            if tmux list-sessions &>/dev/null; then
                wfxr::tmux-attach
            else
                tmux new-session -A -s "misc"
            fi
        fi
    else
        if [[ $TMUX ]]; then
            if ! tmux has-session -t "$1" 2>/dev/null; then
                tmux new-session -d -s "$1"
            fi
            tmux switch-client -t "$1"
        else
            tmux new-session -A -s "$1"
        fi
    fi
    zle redisplay 2>/dev/null || true
}
# https://issue.life/questions/37597191

# greenclip
if (( $+commands[greenclip] )); then
    function clipboard-fzf() {
        CONTENT=$(greenclip print | grep -v '^\s*$' | nl -w2 -s' ' | fzf | sed -E 's/^ *[0-9]+ //')
        BUFFER="$BUFFER$CONTENT"
        CURSOR="$#BUFFER"
        zle redisplay
    }
    zle -N clipboard-fzf

    function greenclip-cfg() {
      killall greenclip; $EDITOR ~/.config/greenclip.toml &&
        nohup greenclip daemon &>/dev/null &
    }
    function greenclip-reload() {
      killall greenclip; nohup greenclip daemon &>/dev/null &
    }
    function greenclip-clear() {
      killall greenclip; rm ~/.cache/greenclip.history &&
        nohup greenclip daemon &>/dev/null &
    }
fi

if (( $+commands[copyq] )); then
    function fcq-zle() {
        CONTENT=$(\
            copyq eval -- \
              "tab('&clipboard'); for(i=size(); i>0; --i) print(str(read(i-1)) + '\n');" \
              | rg -v '^\s*$' \
              | nl -w2 -s" " \
              | tac \
              | fzf --layout=reverse --multi --prompt='Copyq> ' --tiebreak=index \
              | perl -pe 's/^\s*\d+\s?//g && chomp if eof' \
              | xsel -b
        )
        BUFFER="$BUFFER$CONTENT"
        CURSOR="$#BUFFER"
        zle redisplay
    }
    zle -N fcq-zle
fi
