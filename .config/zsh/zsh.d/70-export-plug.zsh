#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-08                                                   #
#    @module: variables                                                    #
#      @desc: Variables that aren't needed for startup                     #
#===========================================================================

# === Variables ========================================================== [[[
# LS_COLORS defined before zstyle
typeset -gx LS_COLORS="$(vivid -d $ZDOTDIR/zsh.d/vivid/filetypes.yml generate $ZDOTDIR/zsh.d/vivid/kimbie.yml)"
typeset -gx {ZLS_COLORS,TREE_COLORS}="$LS_COLORS"
typeset -gx JQ_COLORS="1;30:0;39:1;36:1;39:0;35:1;32:1;32:1"

typeset -gx NQDIR="/tmp/nq"
typeset -gx FNQ_DIR="$HOME/tmp/fnq"
typeset -gx PASSWORD_STORE_ENABLE_EXTENSIONS='true'

typeset -gx PDFVIEWER='zathura' # texdoc pdfviewer
typeset -gx GPG_TTY=$TTY
# ]]]

# === Zsh Plugin Variables =============================================== [[[
typeset -gx ZSH_AUTOSUGGEST_USE_ASYNC=set
typeset -gx ZSH_AUTOSUGGEST_MANUAL_REBIND=set
typeset -gx ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
typeset -gx ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c100,))' # no 100+ char
typeset -gx ZSH_AUTOSUGGEST_COMPLETION_IGNORE="[[:space:]]*" # no leading space
typeset -gx ZSH_AUTOSUGGEST_STRATEGY=(
  histdb_top_here   dir_history
  custom_history    match_prev_cmd
  completion
)
typeset -gx ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  vi-find-next-char  vi-find-next-char-skip
  # forward-word       vi-forward-blank-word   vi-forward-blank-word-end
  # vi-forward-word    vi-forward-word-end
  # forward-char       vi-forward-char
  end-of-line        vi-add-eol              vi-end-of-line
)
typeset -gx HISTORY_SUBSTRING_SEARCH_FUZZY=set
typeset -gx HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=set
typeset -gx AUTOPAIR_CTRL_BKSPC_WIDGET=".backward-kill-word"
typeset -ga chpwd_dir_history_funcs=( "_dircycle_update_cycled" ".zinit-cd" )
typeset -g  PER_DIRECTORY_HISTORY_BASE="${ZPFX}/share/per-directory-history"
# ]]]

# === Fzf ================================================================ [[[
# I have custom colors for 1-53. They're set in alacritty
# If this is an array, even if they're joined, vim doesn't like that
FZF_COLORS="\
  --color=fg:42,fg+:53,hl:22:bold,hl+:23,bg+:-1
  --color=query:51,info:43:bold,border:33,separator:51,scrollbar:51
  --color=label:27,preview-label:27
  --color=pointer:17,marker:19,spinner:13
  --color=header:12,prompt:18"

FZF_HISTFILE="$XDG_CACHE_HOME/fzf/history"
FZF_FILE_PREVIEW="([[ -f {} ]] && (bkt -- bat --style=numbers --color=always -- {}))"
FZF_DIR_PREVIEW="([[ -d {} ]] && (bkt -- exa -T {} | bat --color=always))"
FZF_BIN_PREVIEW="([[ \$(file --mime-type -b {}) = *binary* ]] && (echo {} is a binary file))"

export FZF_COLORS FZF_HISTFILE FZF_FILE_PREVIEW FZF_DIR_PREVIEW FZF_BIN_PREVIEW

export FZF_DEFAULT_OPTS="
--prompt='❱ '
--pointer='》'
--marker='▍'
--separator=''
--info='inline: ❰ '
--scrollbar='█'
--ellipsis=''
--cycle
$FZF_COLORS
--reverse
--ansi
--multi
--border
--height=80%
--tabstop=4
--history=$FZF_HISTFILE
--jump-labels='abcdefghijklmnopqrstuvwxyz'
--preview-window=':hidden,right:60%:border-double'
--preview=\"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='esc:abort'
--bind='ctrl-c:abort'
--bind='ctrl-q:abort'
--bind='ctrl-g:cancel'
--bind='ctrl-j:down'
--bind='ctrl-k:up'
--bind='home:beginning-of-line'
--bind='end:end-of-line'
--bind='ctrl-s:beginning-of-line'
--bind='ctrl-e:end-of-line'
--bind='alt-x:unix-line-discard'
--bind='alt-c:unix-word-rubout'
--bind='alt-d:kill-word'
--bind='ctrl-h:backward-delete-char'
--bind='alt-bs:backward-kill-word'
--bind='ctrl-w:backward-kill-word'
--bind='alt-a:toggle-all'
--bind='ctrl-alt-a:toggle-all+accept'
--bind='alt-s:toggle-sort'
--bind='ctrl-r:clear-selection'
--bind='page-up:prev-history'
--bind='page-down:next-history'
--bind='alt-{:prev-history'
--bind='alt-}:next-history'
--bind='alt-shift-up:prev-history'
--bind='alt-shift-down:next-history'
--bind='alt-left:first'
--bind='alt-right:last'
--bind='alt-up:prev-selected'
--bind='alt-down:next-selected'
--bind='ctrl-u:half-page-up'
--bind='ctrl-d:half-page-down'
--bind='ctrl-alt-u:page-up'
--bind='ctrl-alt-d:page-down'
--bind='alt-enter:replace-query+print-query'
--bind='ctrl-/:jump'
--bind='?:toggle-preview'
--bind='alt-[:toggle-preview'
--bind='alt-]:change-preview-window(70%|45%,down,border-top|45%,up,border-bottom|)+show-preview'
--bind='alt-w:toggle-preview-wrap'
--bind='ctrl-b:preview-page-up'
--bind='ctrl-f:preview-page-down'
--bind='alt-i:preview-page-up'
--bind='alt-o:preview-page-down'
--bind='ctrl-alt-b:preview-up'
--bind='ctrl-alt-f:preview-down'
--bind='alt-e:become($EDITOR {+})'
--bind='alt-b:become(bat --paging=always -f {+})'
--bind='ctrl-y:execute-silent(xsel --trim -b <<< {+})'
--bind='ctrl-]:preview(bat --color=always -l bash \"$XDG_DATA_HOME/gkeys/fzf\")'
--bind='alt-/:unbind(?)'
--bind='ctrl-\\:rebind(?)'
--bind='f2:unbind(?)'
--bind='f3:rebind(?)'
--bind='change:first'"

# FIX: these sometimes work sometimes don't
# --bind='alt-{:prev-history'
# --bind='alt-}:next-history'

# --bind='shift-up:'
# --bind='shift-down:'
# --bind='alt-shift-up:'
# --bind='alt-shift-down:'
# --bind='alt-shift-left:'
# --bind='alt-shift-right:'

# --bind='ctrl-\\:rebind(?)+rebind(<)+rebind(>)'
# --bind='alt-!:unbind(<)'
# --bind='alt-@:unbind(>)'
# --bind=\"alt-':beginning-of-line\"
# --bind='alt-\":end-of-line'

# --separator='━'

export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_COMMAND="\
  (git ls-tree -r --name-only HEAD | lscolors ||
         rg --files --no-ignore --hidden -g '!{.git,node_modules,target}/*') 2> /dev/null"

export FZF_ALT_E_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_E_OPTS="\
  --preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
  --bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
  --preview-window default:right:60%"
export FZF_CTRL_R_OPTS="\
  --preview='echo {}'
  --preview-window='down:2:wrap'
  --bind='ctrl-y:execute-silent(echo -n {2..} | xclip -r -selection c)+abort'
  --header='Press CTRL-Y to copy command into clipboard'
  --exact
  --expect=ctrl-x"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="\
  fd --no-ignore --hidden --follow --strip-cwd-prefix --exclude '.git' --type d -d 1 | lscolors"
export FZF_ALT_C_OPTS="\
  --preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
  --bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
  --preview-window default:right:60%"

# (( $+commands[fd] )) && {
#     _fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1" }
#     _fzf_compgen_dir()  { fd --type d --hidden --follow --exclude ".git" . "$1" }
# }
# ]]]

# === Skim =============================================================== [[[
typeset -a SKIM_COLORS=(
  "fg:42" "fg+:53" "hl:22" "hl+:#689d6a" "bg+:-1" "marker:#fe8019"
  "spinner:#b8bb26" "header:#cc241d" "prompt:#fb4934"
)

SKIM_DEFAULT_OPTIONS="\
  --prompt '❱ '
  --cmd-prompt 'c❱ '
  --cycle
  --reverse --height 80% --ansi --inline-info --multi --border
  --preview-window=':hidden,right:60%'
  --preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
  --bind='?:toggle-preview,alt-w:toggle-preview-wrap'
  --bind='alt-a:select-all,ctrl-r:toggle-all'
  --bind='alt-b:execute(bat --paging=always -f {+})'
  --bind=\"ctrl-y:execute-silent(ruby -e 'puts ARGV' {+} | xsel --trim -b)+abort\"
  --bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
  --bind='ctrl-s:toggle-sort'
  --bind='ctrl-b:preview-up,ctrl-f:preview-down'
  --bind='ctrl-k:preview-up,ctrl-j:preview-down'
  --bind='ctrl-u:half-page-up,ctrl-d:half-page-down'"

# SKIM_DEFAULT_OPTIONS=${(F)${(M)${(@f)FZF_DEFAULT_OPTS}/(#m)*info*/${${(@s. .)MATCH}:#--info*}}:#--(bind=change:top|pointer*|marker*|color*)}
# SKIM_DEFAULT_OPTIONS+=$'\n'"--cmd-prompt=➤"
# SKIM_DEFAULT_OPTIONS+=$'\n'"--bind='ctrl-p:preview-up,ctrl-n:preview-down'"
SKIM_DEFAULT_OPTIONS+=$'\n'"--color=${(j:,:)SKIM_COLORS}"
export SKIM_DEFAULT_OPTIONS

export SKIM_COMPLETION_TRIGGER='~~'
export SKIM_DEFAULT_COMMAND='fd --no-ignore --hidden --follow --exclude ".git"'
export SKIM_CTRL_R_OPTS="\
  --preview='echo {}'
  --preview-window=':hidden,down:2:wrap'
  --bind='ctrl-y:execute-silent(echo -n {2..} | xclip -r -selection c)+abort'
  --header='Press CTRL-Y to copy command into clipboard'
  --exact
  --expect=ctrl-x"
export SKIM_ALT_C_COMMAND="$FZF_ALT_C_COMMAND"
# ]]]

# === Fzf Plugins ======================================================== [[[

## Zoxide
# typeset -gx _ZO_ECHO=1
typeset -gx _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview='(exa -T {2} | less) 2>/dev/null | head -200'"

## FzfGit
typeset -gx FZFGIT_BACKUP="${XDG_DATA_HOME}/gitback"
typeset -gx FZFGIT_DEFAULT_OPTS="--preview-window=':nohidden,right:65%:wrap'"

## Forgit
typeset -gx FORGIT_LOG_FORMAT="%C(red)%C(bold)%h%C(reset) %Cblue%an%Creset: %s%Creset%C(yellow)%d%Creset %Cgreen(%cr)%Creset"
typeset -gx FORGIT_FZF_DEFAULT_OPTS="--preview-window='right:60%:nohidden' --bind='ctrl-e:become(nvim {2})'"

## Dotbare
alias db='dotbare'
export DOTBARE_DIR="${XDG_DATA_HOME}/dotfiles"
export DOTBARE_TREE="$HOME"
export DOTBARE_BACKUP="${XDG_DATA_HOME}/dotbare-b"
export DOTBARE_FZF_DEFAULT_OPTS="\
  $FZF_DEFAULT_OPTS
  --header='M-a:select-all, C-b:pager, C-y:copy, C-e:nvim'
  --preview-window=:nohidden
  --preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\""
# ]]]
