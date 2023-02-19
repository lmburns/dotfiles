##################################################################################
# OTHER
##################################################################################

function num() {
  (( $# == 0 )) && {
    tr '[:lower:]' '[:upper:]' | numfmt --from iec
  } || numfmt --from iec "${(U)@}"
}

function fnum() {
  (( $# == 0 )) && {
    numfmt --to iec
  } || numfmt --to iec "${@}"
}

function fzf-dmenu() {
  local selected="$(\
    command ls /usr/share/applications \
      | sed 's/\(.*\)\.desktop/\1/g' \
      | fzf -e
  ).desktop"
  [[ -n "${selected%.desktop}" && $? -eq 0 ]] && {
    nohup $(\
      grep '^Exec' "/usr/share/applications/$selected" \
        | tail -1 \
        | sed 's/^Exec=//' \
        | sed 's/%.//'
    ) >/dev/null 2>&1 &
  }
}

# remove broken symbolics
function wfxr::rm-broken-links() {
  local ls; local -a links
  (( $+commands[exa] )) && ls=exa || ls=ls
  links=( ${(@f)"$(find ${(z)1} -xtype l)"} )
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

function rm::broken-links-all() { wfxr::rm-broken-links               }
function rm::broken-links()     { wfxr::rm-broken-links '-maxdepth 1' }

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
  eval "[[ \${(t)$1} = association ]]" || {
    print::error "$1 is not a hash"
    return 1
  }

  eval "\
    for k ( \"\${(@k)$1}\" ) {
      print -Pr \"%F{2}\$k%f %F{1}%B=>%f%b %F{3}\$$1[\$k]%f\"
    }
  "
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

#  ╭──────────────────────────────────────────────────────────╮
#  │                        greenclip                         │
#  ╰──────────────────────────────────────────────────────────╯
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
              | perl -pe 's/^\s*\d+\s?//g && chomp if eof'
        )
        BUFFER="$BUFFER$CONTENT"
        CURSOR="$#BUFFER"
        zle redisplay
    }
    zle -N fcq-zle
fi
