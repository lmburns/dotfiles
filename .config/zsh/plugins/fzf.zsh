# @desc: select a docker container to remove
function f1dockrm() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker rm "$cid"
}

# @desc: select a docker container to start and attach to
function f1docka() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker start "$cid" && docker attach "$cid"
}

# @desc: select a docker image or images to remove
function f1dockrmi() {
  docker images | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi
}

# @desc: select a running docker container to stop
function f1docks() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker stop "$cid"
}

# @desc: use fzf to bring job to foreground
function f1fg() {
  local job
  job="$(builtin jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && print '' && fg %$job;
}

function f1uni() {
  ruby \
    -e '0x100.upto(0xFFFF) do |i| puts "%04X%8d%6s" % [i, i, i.chr("UTF-8")] rescue true end' \
  | fzf -m
}

# @desc: choose a process to list open files
function f1lsof() {
  local pid args; args=${${${(M)UID:#0}:+-f -u $UID}:--fe}
  pid=$(ps ${(z)args} | sed 1d | fzf -m | awk '{print $2}')
  dunstify $pid
  (( $+pid )) && {
    LBUFFER="lsof -p $pid"
    (($+WIDGET)) && zle zredraw-prompt
  }
}; zle -N f1lsof

# @desc: change directories with fzf
function fcd-zle() {
  local dir
  dir=$(fd ${1:-.} --prune -td | fzf +m)
  if [[ -d "$dir" ]]; then
    builtin cd "$dir"
    (($+WIDGET)) && zle zredraw-prompt
  else
    (($+WIDGET)) && zle redisplay
  fi
}; zle -N fcd-zle

# @desc: cd to selected parent directory
function f1bd() {
  local d
  local -a dirz=()
  function get_parent_dirs() {
    if [[ -d "$1" ]] { dirz+=("$1") } else { return }
    if [[ "$1" == '/' ]] { print -rl -- "${dirz[@]}" | lscolors } else { get_parent_dirs "${1:h}" }
  }
  local d="$(\
    get_parent_dirs "${${1:-$PWD}:A}" \
      | fzf +m \
          --preview='[[ -d {} ]] && (bkt -- exa -T {} | bat --color=always)' \
          --preview-window='right:hidden:wrap' \
          --bind=ctrl-v:toggle-preview \
          --bind=ctrl-x:toggle-sort \
          --header='(view:ctrl-v) (sort:ctrl-x)' \
  )"
  [[ -n "$d" ]] && builtin cd "$d"
}
functions -c f1bd zdr

# @desc: search ctags
function f1tags() {
  local line
  [[ -e tags ]] &&
    line=$(
      awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
        cut -c1-80 | fzf --nth=1,2
      ) && ${EDITOR:-vim} $(cut -f3 <<< "$line") -c "set nocst" \
                          -c "silent tag $(cut -f2 <<< "$line")"
}

# @desc: search environment vars with fzf
function f1env() {
  local out
  out=$(fzf <<<${(@f)"$(env)"})
  [[ -n $out ]] && hck -d '=' -f2<<<$out
}

# @desc: search set items
function f1set() {
  local out
  out=$(fzf <<<${(F)${(@f)"$(set)"}//prompt=*/})
  [[ -n $out ]] && hck -d '=' -f2<<<$out
}

# @desc: figlet font selector
function f1fig() (
  emulate -L zsh
  builtin cd -q /usr/share/figlet/fonts
  command ls *.flf | sort | fzf --no-multi --reverse --preview "figlet -f {} Hello World!"
)

# @desc: search JRNL headlines
function f1jrnl() {
  local title
  title=$(jrnl --short | fzf --tac --no-sort)
  jrnl -on "$(echo $title | cut -c 1-16)" $1
}

# @desc: open file interactively with twf
# @depends: twf
function f1twf() {
  local -a files; files=("$(
    twf \
      --height=0.8 \
      --previewCmd='([[ -f {} ]] && (bat --style=numbers --color=always {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
  )") || return
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# @desc: fzf mpd
# @depends: fzf-tmux, mpc
function f1mpc() {
  local song_pos; song_pos=$(\
    mpc -f "%position%) %artist% - %title%" playlist \
      | fzf-tmux --query="$1" --reverse --select-1 --exit-0 \
      | sed -n 's/^\([0-9]\+\)).*/\1/p') \
    || return 1
  [[ -n "$song_pos" ]] && mpc -q play $song_pos
}

# @desc: search directory for pdf and open in zathura
function f1pdf() {
  local prog='zathura'

  fd --no-ignore-vcs -tf -e pdf \
    | fast-p \
    | fzf \
        --read0 \
        --reverse \
        --delimiter $'\t'  \
        --preview-window='nohidden,down:80%' \
        --preview='local v=$(print -r {q} | tr " " "|");
                   print -- {1}"\n"{2} | grep -E "^|$v" -i --color=always;' \
    | cut -z -f 1 -d $'\t' \
    | tr -d '\n' \
    | xargs -r --null $open > /dev/null 2> /dev/null
}

#  ╭──────────────────────────────────────────────────────────╮
#  │                           ZLE                            │
#  ╰──────────────────────────────────────────────────────────╯

# @desc: ALT-E - Edit selected file
function fzf-file-edit-widget() {
  setopt localoptions pipefail
  local files
  files=$(eval "$FZF_ALT_E_COMMAND" |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_E_OPTS" fzf -m |
      sed 's/^\s\+.\s//')
  local ret=$?

  [[ $ret -eq 0 ]] && echo $files | xargs sh -c "$EDITOR \$@ </dev/tty" $EDITOR

  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}; zle -N fzf-file-edit-widget
# Zkeymaps[Esc-f]=fzf-file-edit-widget

# @desc: zle edit file
function f1zfe() {
  local -a sel
  sel=("$(rgf --bind='enter:accept' --multi)")
  [[ -n "$sel" ]] && ${EDITOR:-vim} "${sel[@]}"
  (( $+WIDGET )) && {
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  }
}; zle -N f1zfe
Zkeymaps[Esc-f]=f1zfe
# FIX: this doesn't work anymore
# Zkeymaps[Esc-i]='f1zfe 2'

# @desc: use FZF and histdb
function :fzf-histdb() {
  local query="
SELECT commands.argv
FROM   history
  LEFT JOIN commands
    ON history.command_id = commands.rowid
  LEFT JOIN places
    ON history.place_id = places.rowid
GROUP BY commands.argv
ORDER BY places.dir != '${PWD//'/''}',
    commands.argv LIKE '${BUFFER//'/''}%' DESC,
    Count(*) DESC
"
  local selected=$(_histdb_query "$query" | ftb-tmux-popup -n "2.." --tiebreak=index --prompt="cmd> " ${BUFFER:+-q$BUFFER})

  # local selected=$(fc -rl 1 | ftb-tmux-popup -n "2.." --tiebreak=index --prompt="cmd> " ${BUFFER:+-q$BUFFER})
  # if [[ "$selected" != "" ]] {
  #   zle vi-fetch-history -n $selected
  # }

  BUFFER=${selected}
  CURSOR=${#BUFFER}
}; zle -N :fzf-histdb
Zkeymaps+=('C-x r' :fzf-histdb)

function :fzf-find() {
  local selected dir cut
  cut=$(grep -oP '[^* ]+(?=\*{1,2}$)' <<< $BUFFER)
  eval "dir=${cut:-.}"
  if [[ $BUFFER == *"**"* ]] {
    selected=$(fd -H . $dir \
      | ftb-tmux-popup --tiebreak=end,length --prompt="cd> " --border=none)
  } elif [[ $BUFFER == *"*"* ]] {
    selected=$(fd -d 1 . $dir \
      | ftb-tmux-popup --tiebreak=end --prompt="cd> " --border=none)
  }
  BUFFER=${BUFFER/%'*'*/}
  BUFFER=${BUFFER/%$cut/$selected}
  zle end-of-line
}; zle -N :fzf-find
Zkeymaps+=('C-x C-f' :fzf-find)

# @desc: cd GHQ with fzf
function fzf-ghq() {
  local repo
  repo=$(\
    command ghq list -p \
      | xargs ls -dt1 \
      | lscolors \
      | fzf --ansi \
            --no-multi \
            --prompt='GHQ> ' \
            --reverse \
            --height 50% \
            --preview="\
            bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*" \
            --preview-window="right:50%" \
            --delimiter / \
            --with-nth 5..
  )
  # f={}; bkt -- exa -T --color=always -L3 -- $(sed "s#.*→  ##" <<<"$f")' \
  [[ -d "$repo" ]] && {
    if (( $+WIDGET )); then
      BUFFER="cd $repo"
      zle accept-line
    else
      builtin cd "$repo"
    fi
  }
}; zle -N fzf-ghq
Zkeymaps[M-x]=fzf-ghq

# @desc: bring up jobs with fzf
function f1z-ctrlz() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER=" f1fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}; zle -N f1z-ctrlz
Zkeymaps[C-z]=f1z-ctrlz

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

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]:
