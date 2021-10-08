#===========================================================================
#       Author: Lucas Burns
#        Email: burnsac@me.com
#      Created: 2021-06-27 21:50
#  Description: Bindkeys for zsh using custom 'vbindkey'
#===========================================================================

# zshexpn -- zsh -o SOURCE_TRACE -lic ''
# sed -n l -- infocmp -L1 -- zle -L

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )) {
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
}

builtin bindkey -v
builtin bindkey -r '^[,'
builtin bindkey -r '^[/'
builtin bindkey -M vicmd -r 'R'

# bindkey -M vicmd 'ys' add-surround
# bindkey '^I' expand-or-complete-prefix
# bindkey '^a' autosuggest-accept

autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz replace-string
# zle -N replace-pattern replace-string
zle -N replace-regex replace-string

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround

per-dir-fzf() {
  if [[ $_per_directory_history_is_global ]]; then
    per-directory-history-toggle-history; fzf-history-widget
  else
    fzf-history-widget
  fi
}

zle -N per-dir-fzf       # fzf history

# Results aren't shown immediately
RG_buff() {
  zmodload -Fa zsh/parameter p:functions
  eval "() {
    $functions[RG]
  }" "$BUFFER"
  zle reset-prompt
}

zle -N RG_buff

__ftag_local() { ftag -l ; }
zle -N __ftag_local

zle -N fcq
zle -N pw
zle -N fe

zle -N expand-aliases

# zle -N __rualdi_fzf

# zle -N fcd-zle
# zle -N bow2

zle -N __unicode_translate # translate unicode to symbol

if [[ $TMUX ]]; then
  zle -N t
  vbindkey 'M-t' t                       # alt-t
  zle -N wfxr::tmux-select-window
  vbindkey 'M-S-w' wfxr::tmux-select-window # alt-w
fi

# Available modes: all normal modes, str, @, -, + (see marlonrichert/zsh-edit)
typeset -gA keybindings; keybindings=(
  'Home'          beginning-of-line
  'End'           end-of-line
  'Delete'        delete-char
  'F1'            dotbare-fstat
  'F2'            db-faddf
  'F3'            _wbmux
  'Esc-e'         wfxr::fzf-file-edit-widget
  'Esc-i'         fe
  'Esc-d'         expand-aliases
  'M-r'           per-dir-fzf
  'M-p'           pw                    # fzf pueue
  'M-q'           push-line-or-edit     # zsh-edit
  'M-u'           __unicode_translate   # translate unicode
  'M-x'           cd-fzf-ghqlist-widget # cd ghq fzf
  'C-a'           autosuggest-execute
  'C-y'           yank
  'C-z'           fancy-ctrl-z
  'C-x r'         fz-history-widget
  'C-x t'         pick_torrent          # fzf torrent
  'C-x C-b'       fcq                   # copyq fzf
  'C-x C-e'       edit-command-line-as-zsh
  'C-x C-f'       fz-find
  'C-x C-u'       RG_buff
  'C-x C-x'       execute-command
  'mode=vicmd u'  undo
  # 'mode=vicmd R' replace-pattern
  'mode=vicmd R'  replace-regex
  'mode=vicmd U'  redo
  'mode=vicmd E'  backward-kill-line
  'mode=vicmd L'  end-of-line
  'mode=vicmd H'  beginning-of-line
  'mode=vicmd ?'  which-command
  'mode=vicmd ge' edit-command-line-as-zsh
  'mode=vicmd c.' vi-change-whole-line
  'mode=vicmd ds' delete-surround
  'mode=vicmd cs' change-surround
  'mode=vicmd K'  run-help
  'mode=viins jk' vi-cmd-mode
  'mode=viins kj' vi-cmd-mode
  'mode=visual S' add-surround
  'mode=str M-t'  t                     # tmux wfxr
  'mode=str C-o'  lc                    # lf change dir
  'mode=str C-_'  lf
  'mode=@ C-b'    bow2                  # surfraw open w3m
  'mode=+ M-.'    kf                    # a formarks like thing in rust
  'mode=@ M-/'    frd                   # cd interactively recent dir
  'mode=@ M-;'    fcd                   # cd interactively
  'mode=@ M-,'    __zoxide_zi
  'mode=@ M-['   fstat
  'mode=@ M-]'   fadd
  'mode=@ M-f'   __ftag_local
)

# 'mode=@ C-o'    lc                    # lf change dir
# 'mod=vicmd ZZ'  accept-line
# 'mode=vicmd M-a' yank-pop
# 'mode=vicmd M-s' reverse-yank-pop

# M-/ = cd interactively recent dir
# M-; = cd interactively
# M-. = formarks
# M-, = zoxide

# 'M-c'     _call_navi
# 'M-n'     _navi_next_pos

vbindkey -A keybindings

# # ci", ci', ci`, di", etc
# autoload -U select-quoted
# zle -N select-quoted
# for m in visual viopp; do
#   for c in {a,i}{\',\",\`}; do
#     bindkey -M $m $c select-quoted
#   done
# done
#
# # ci{, ci(, ci<, di{, etc
# autoload -U select-bracketed
# zle -N select-bracketed
# for m in visual viopp; do
#   for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
#     bindkey -M $m $c select-bracketed
#   done
# done

# View keybindings
keyb() {
  local -A keyb=(); for k v in ${(kv)keybindings}; do
    k="%F{1}%B$k%f%b" v="%F{3}$v%f" keyb[${(%)k}]=${(%)v}
  done
  print -raC 2 -- ${(Oakv)keyb[@]}
  # print -rC 2 -- ${(nkv)keyb}
  # print -ac -- ${(Oa)${(kv)keyb[@]}}
}
