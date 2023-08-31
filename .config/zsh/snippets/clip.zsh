function detect-clip() {
  emulate -L zsh
  function ccopy()  { xsel -bi --trim < "${1:-/dev/stdin}"; }
  function cpaste() { xsel -b; }
}

detect-clip || true

if (( $+commands[greenclip] )); then
    # @desc: greenclip fzf (insert into cli)
    function :fzf-greenclip() {
        local CONTENT
        CONTENT=$(greenclip print | rg -v '^\s*$' | nl -w2 -s' ' | fzf | sed -E 's/^ *[0-9]+ //')
        BUFFER="$BUFFER$CONTENT"
        CURSOR="$#BUFFER"
        zle redisplay
    }
    zle -N :fzf-greenclip
    Zkeymaps[C-o]=:fzf-greenclip

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
    # @desc: copyq zle (insert contents)
    function __fzf-copyq() {
      typeset -g REPLY
      REPLY=$(\
        copyq eval -- \
          "tab('&clipboard'); for(i=size(); i>0; --i) print(str(read(i-1)) + '\n');" \
          | rg -v '^\s*$' \
          | nl -w2 -s" " \
          | tac \
          | fzf --layout=reverse --multi --prompt='Copyq> ' --tiebreak=index \
          | perl -pe 's/\d+\s?//g && chomp if eof'
      )
    }

    function :fzf-copyq() {
        __fzf-copyq
        BUFFER="$BUFFER$REPLY"
        CURSOR="$#BUFFER"
        zle redisplay
    }
    zle -N :fzf-copyq
    Zkeymaps+=('mode=vicmd ;v' :fzf-copyq)

    # @desc: use copyq to view clipboard history (non-tmux)
    function fzf-copyq() {
        __fzf-copyq
        xsel -b --input --trim <<< $REPLY
        zle redisplay
    }
    zle -N fzf-copyq
    # Zkeymaps+=('C-x C-g' fzf-copyq)
fi
