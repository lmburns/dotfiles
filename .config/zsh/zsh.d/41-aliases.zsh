#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2021-06-15                                                   #
#    @module: aliases                                                      #
#      @desc: Aliases for zsh                                              #
#===========================================================================

# alias tlmgr="/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode"
# alias mail='/usr/bin/mail'
# alias strace="/usr/local/bin/strace"
# alias xevk="xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'"

alias -g G='| rg '      H='| head '           T='| tail '
alias -g U='| uniq '    C='| column -t '
alias -g K='| hck'      KF='| hck -f'         KD='| hck -d'     TRIM='| cut -c 1-$COLUMNS'
alias -g CW='| cw '     R='| tac '            W='| w3m '
alias -g F='| fzf '     Y='| xsel -ib --trim' A='--color=always '
alias -g S='| sort '    SU='| sort -u'        SN='| sort -n'     SNR='| sort -nr'
alias -g WR='| while read -r line { print -r -- "$line" }'
alias -g WRD='| while read -r line { aria2c "$line" }'

alias -g N='>/dev/null'                       NO='&>/dev/null'    NUL='2>/dev/null 2>&1'
alias -g 1N='1>/dev/null'  2N='2>/dev/null'   NN='&>/dev/null'    NE='2>/dev/null 2>&1'
alias -g NS='3>&2 2>&1 1>&3 3>&-'             DN='/dev/null'      NA='2>&1'
alias -g NB='|& bat -f --paging=always'       NBA='|& bat -f --paging=always --show-all'

# alias -g W="!"
# alias -g PI="|"

alias -g B='| bat -f '  L='| bat -f --style=rule,snip,changes '  P='| bat -pf --paging=always '
alias -g LS='| BAT_PAGER="less $LESS -S" bat -f --paging=always'

#        Any file          Regular file        Directory           Executable         Symlink
alias -g CN="-- *(oc[1])"  CNF="-- *(oc[1].)"  CND="-- *(oc[1]/)"  CNX="-- *(oc[1]*)" CNL="-- *(oc[1]@)" # inode change (new)
alias -g CO="-- *(Oc[1])"  COF="-- *(Oc[1].)"  COD="-- *(Oc[1]/)"  COX="-- *(Oc[1]*)" COL="-- *(Oc[1]@)" # inode change (old)
alias -g AN="-- *(oa[1])"  ANF="-- *(oa[1].)"  AND="-- *(oa[1]/)"  ANX="-- *(oa[1]*)" ANL="-- *(oa[1]@)" # access time (new)
alias -g AO="-- *(Oa[1])"  AOF="-- *(Oa[1].)"  AOD="-- *(Oa[1]/)"  AOX="-- *(Oa[1]*)" AOL="-- *(Oa[1]@)" # access time (old)
alias -g MN='-- *(om[1])'  MNF='-- *(om[1].)'  MND='-- *(om[1]/)'  MNX='-- *(om[1]*)' MNL='-- *(om[1]@)' # modification time (new)
alias -g MO='-- *(Om[1])'  MOF='-- *(Om[1].)'  MOD='-- *(Om[1]/)'  MOX='-- *(Om[1]*)' MOL='-- *(Om[1]@)' # modification time (old)

#        Type          Type empty            Type not empty
alias -g TA='-- *(,)'  TAE='-- *(-.L0,-/^F)' TAF='-- *(-.^L0,-/F)' # all
alias -g TD='-- *(-/)' TDE='-- *(-/^F)'      TDF='-- *(-/F)'       # directory
alias -g TF='-- *(-.)' TFE='-- *(-.L0)'      TFF='-- *(-.^L0)'     # file

alias {\$,%}=

alias ziu='zi update'
alias zid='zi delete'

# === zsh-help ==============================================================
alias lynx="command lynx -vikeys -accept-all-cookies"
alias zman="BROWSER=$BROWSERCLI zman"
alias wman="w3m-man -H"
alias iinfo='command info --vi-keys'
alias info='command pinfo'

alias wi="whatis"           # what is the program
alias wh="whence -Sacx4"    # list all, csh style
alias wa="whence -Sav"      # where
alias wm="whence -Smv"      # pattern, verbose
alias wma="whence -Smav"    # pattern, list all, verbose
alias wmf="whence -Smafvx4" # pattern, list all, verbose, function content

# === general ===================================================================
# alias _='sudo'
# alias __='doas'
alias usudo='sudo -E -s '
alias c='cdr'
alias f='pushd'
alias b='popd'
alias dirs='dirs -v'
alias unset='noglob unset'
alias ng="noglob"

alias zstats='zstat -sF "%b %e %H:%M:%S"'
alias clear='clear -x' # don't clear scrollback buffer
alias sane='stty sane'
alias plast="last -20"
alias :q='exit'

alias pl='print -rl --'
alias pp='print -Pr --'
alias pz='print -Prl --'
alias plm='pl $match[@]'
alias plM='pl $MATCH'
alias plr='pl $reply[@]'
alias plR='pl $REPLY'
alias ret='pp "%F{%(?,10,9)}%B%(?,0,1)%b%f"'
# alias ret='pp ${?//(#m)*/${${${(M)MATCH:#0}:+$fg_bold[green]0}:-$fg_bold[red]$MATCH}}'

alias chx='command chmod ug+x'
alias chmx='command chmod -x'
alias cp='command cp -ivp --reflink=auto'
alias cpl='command cp -ivpa'
alias cpa='command cp -ivp --preserve=links,mode,ownership,xattr'
alias cpx='command cp -ivp --preserve=xattr'
alias mv='command mv -iv'
alias lns='command ln -siv'

# [[ -n "$NVIM_LISTEN_ADDRESS" ]] && alias nvim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
alias pvim='nvim -u NONE'
alias vi="$EDITOR"
alias svi="sudo $EDITOR"
alias nd='neovide'
alias vimdiff='nvim -d'

alias grep="command grep --color=auto --binary-files=without-match --directories=skip"
alias diff='command diff --color=auto'
alias sha='shasum -a 256'

(( ! ABSD )) && {
  alias jor="journalctl"
  alias jortoday="journalctl -xe --since=today"
  alias s="systemctl"
  alias se="systemctl --user"
  alias bctl="bluetoothctl"
  alias open="handlr open"
  alias xmm="xmodmap"
}

(( ! ABSD )) && {
  alias pbcopy="xsel --clipboard --input --trim"
  alias pbpaste="xsel --clipboard --output"
  alias xclipi='xclip -in -selection clipboard -rmlastnl'
  alias xclipo='xclip -out -selection clipboard'
}
alias xseli='xsel --clipboard --input --trim'
alias xselo='xsel --clipboard --output'
alias pbc='pbcopy'
alias pbp='pbpaste'

alias lsofw='lsof -w'
alias n1lsfp='lsof -w -p' # Open files of process
alias n1sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias n1httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias kid='kill -KILL'
alias kall='killall'
alias zcount='pgrep zsh -c'
alias lfcount='pgrep lf -c'

alias vmst='vmstat -SM 1'
alias iost='iostat -y -d -h -t 1'
alias s1vmst='vmst'
alias s1iost='iost'

(( ${+commands[exa]} )) && {
  # *(Y) = short circuit
  alias ls='exa -Fhb --git --icons'
  alias lss='ls --group-directories-first'                                        # short norm dir-first
  alias lssa='ls -a'                                                              # short all

  alias ll='exa -FlahHgb --git --icons --time-style long-iso --octal-permissions' # long all
  alias lla='ls -l'                                                               # long norm
  alias lls='ll --group-directories-first'                                        # long all dir-first
  alias lj='ll --group-directories-first'
  alias llf='ll --group-directories-first'

  alias ls,='ll -d'  # short list directories like regular files
  alias ll,='ll -d'  # long list directories like regular files

  alias lsp='exa -Fla --no-filesize --no-icons --no-permissions --no-time --no-user' # long plain
  alias lsf='exa -FlaHb@Sig --icons --git --octal-permissions --no-permissions'      # long full
  alias ll2='exa -FlaHBb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@' # long short
  alias lsi='lls --git-ignore' # long ignore from gitignore
  alias lsn='lls --numeric'    # long UID:GID

  autoload -Uz after before

  # --color-scale
  # -I --ignore-glob
  # -S --blocks
  # -i --inode

  alias llb='ll --blocks'
  # Reverse
  alias llr='ll --reverse' # long all rev
  alias llsr='lls --reverse'
  # One per line + indicator
  alias lp='exa -1F'
  alias lpo='lssa -1F'

  # Sort by extension
  alias lse='exa -Flhb --git --sort=extension --icons'
  alias lle='ll --sort=extension'

  # Sort by modified
  alias lsm='ll --sort=modified --modified'
  alias lsmr='ll --sort=modified --reverse'
  # 10 oldest files (modified)
  alias lsmo='lsm -- *(-.DOm[1,10])'
  # 10 newest files (modified)
  alias lsmn='lsm -- *(-.Dom[1,10])'

  # Sort by accessed
  alias lsa='ll --sort=accessed --accessed'
  alias lsr='ll --sort=accessed --accessed --reverse'
  # 10 oldest files (accessed)
  alias lsao='lsa -- *(-.DOa[1,10])'
  # 10 newest files (accessed)
  alias lsan='lsa -- *(-.Doa[1,10])'

  # Sort by changed
  alias lsc='ll --sort=changed --changed'
  alias lscr='ll --sort=changed --changed --reverse'
  # 10 oldest files (changed)
  alias lsco='lsc -- *(-.DOc[1,10])'
  # 10 newest files (changed)
  alias lscn='lsc -- *(-.Doc[1,10])'

  # Sort by created (born)
  alias lsb='ll --sort=created --created'
  alias lsbr='ll --sort=created --created --reverse'
  # 10 oldest files (created)
  # alias lsbo='lsc *(D.Oc[1,10])'
  # 10 newest files (created)
  # alias lsbn='lsc *(D.oc[1,10])'

  # Altered today
  alias lsat='lsc -d -- *(e-after today-N)'
  # Altered before today
  alias lsbt='lsc -d -- *(e-before today-N)'
  # Changed at least 2hrs ago
  alias lsa2='lsc -d -- *(ch+2)'
  # Changed within last 2hrs
  alias lsb2='lsc -d -- *(ch-2)'

  # Sort by size
  # alias lsz='exa -Flhb --git --sort=size --icons'
  alias lsz='ll --sort=size'
  alias lszr='ll --sort=size --reverse'
  # 10 biggest files
  alias lszb='lsz -- *(-.OL[1,10])'
  # 10 smallest files
  alias lszs='lsz -- *(-.oL[1,10])'
  # List empty files
  alias lsz0='lsz -- *(-.L0)'
  alias lsze='lsz0'

  # User: root
  alias lsur='ll -- *(Nu0)'
  alias lst='ll --sort=type'

  alias lsd='exa -D --icons --git'
  # All directories and symlinks that point to dirs
  alias lsdl='ll -d -- *(-/)'
  # 10 oldest directories (changed)
  alias lsdo='ll -d --sort=modified -- *(-/Oc[1,10])'
  # 10 newest directories (changed)
  alias lsdn='ll -d --sort=modified -- *(-/oc[1,10])'
  # Empty directories
  alias lsde='ll -d -- *(-/^F)'
  # Full directories
  alias lsdf='ll -d -- *(-/F)'
  # Just directories 2 levels deep
  alias lsd2='exa -L2 -RD'

  # Setgid/setuid/sticky flag
  alias lsS='ll -- *(s,S,t)'
  alias lsts='lsS'
  # Executables
  alias lsx='ll -- *(*)'
  # World executable
  alias lsX='ll -- *(X)'
  alias lstx='lsx'
  # Symlinks
  alias lsl='ll -d -- *(@N)'
  alias lstl='lsl'

  alias tree='exa --icons --git -TL'
  alias lstr='exa --icons --git -1F@'
  alias ls@='exa -FlaHBb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  # alias ls@='exa -FlaHb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  # alias lm='exa -l  --no-user --no-permissions --no-time -@'

  # Dotfiles
  alias ls.='exa -FHb --git --icons -d -- .*(-.N)'
  alias ll.='ll -d -- .*(-.N)'
  # Dotfiles + dot directories
  alias ls.a='exa -FHb --git --icons -d -- *(-N^D)'
  alias ll.a='ll -d -- *(-N^D)'
  # Not dotfiles
  alias ls.n='exa -FHb --git --icons -d -- *(-.N^D)'
  alias ll.n='ll -d -- *(-.N^D)'
}

(( ${+commands[fd]} )) && {
  alias fd='fd -Hi'                       # hidden; insensitive
  alias fdi='fd -Hi --no-ignore'          # hidden; insensitive; no ignore
  alias ifd='fdi'                         # hidden; insensitive; no ignore
  alias fdg='fd --glob'                   # glob
  alias fdc='fd --color=always'           # color=always
  alias fdr='fd --changed-within=20m -d1' # recent - changed within=20m; depth=1
  alias fdrd='fd --changed-within=30m'    # recent - changed within=30m; depth=inf
  alias fdrr='fd --changed-within=1m'     # really recent - changed within=1m
}

(( ${+commands[rg]} )) && {
  alias prg="rg --pcre2"                # pcre
  alias frg="rg --files-with-matches"   # filenames only
  alias lrg="rg -F"                     # fixed-strings
  alias irg="rg --no-ignore"            # no ignore
  alias RGV='RG -g "*.vim"'             # interactive; vim
  alias RGL='RG -g "*.lua"'             # interactive; lua
  alias RGN='RG -g "*.{lua,vim}"'       # interactive; lua, vim
  alias RGR='RG -g "*.rs"'              # interactive; rust
  alias RGT='RG -g "*.{ts,tsx}"'        # interactive; typescript
  alias RGJ='RG -g "*.{js,jsx}"'        # interactive; javascript
  alias RGE='RG -g "*.{ts,tsx,js,jsx}"' # interactive; .ts, .tsx, .js, .jsx
  alias RGP='RG -g "*.py"'              # interactive; python
  alias RGG='RG -g "*.go"'              # interactive; go
  alias RGZ='RG -g "*.zsh"'             # interactive; zsh
}

(( ${+commands[just]} )) && {
  alias jj='just'
  # For whatever reason, has to be in homedir to have correct completions
  alias .j='just --justfile $HOME/justfile --working-directory $PWD'
  alias .jc='.j --choose'
  alias .je='.j --edit'
  alias .jl='.j --list'
  alias .js='.j --show'
  alias .jr='just --justfile $HOME/projects/rust/rust_justfile --working-directory $PWD'

  # foreach recipe in $(.j --summary) { alias=".j $recipe" }
}

(( ${+commands[hoard]} )) && {
  alias hd='hoard -c $XDG_CONFIG_HOME/hoard/hoard.toml -h $XDG_CONFIG_HOME/hoard/root'
  alias hdy='hoard -c $XDG_CONFIG_HOME/hoard/hoard.yml -h $XDG_CONFIG_HOME/hoard/root'
  alias hde='hoard -c $XDG_CONFIG_HOME/hoard/hoard.toml -h /run/media/lucas/Linux/manual/hoard-bkp'
  alias nhd='$EDITOR $XDG_CONFIG_HOME/hoard/hoard.yml'
  alias hdocs='hoard -c $XDG_CONFIG_HOME/hoard/docs-config -h $XDG_CONFIG_HOME/hoard/docs'
  alias hdocse='hoard -c $XDG_CONFIG_HOME/hoard/docs-config -h /run/media/lucas/Linux/manual/hoard-docs'
  alias nhdocs='$EDITOR $XDG_CONFIG_HOME/hoard/docs-config'
}

[[ -v commands[surfraw] ]] && {
  alias srg='sr -g'
  alias srh='srg github'
  alias srl='BROWSER=$BROWSERCLI sr'
  alias srB='BROWSER=brave srg'
  alias srgg='BROWSER=$BROWSER srg google'
}

[[ -v commands[xidlehook] ]] && {
  alias xidlestop="xidlehook-client --socket /tmp/xidlehook.sock reset-idle"
  alias xidlered="xidlehook-client --socket /tmp/xidlehook.sock control --action Disable --timer 0"
}

(( ${+commands[pet]} )) && {
  alias pe="pet exec"
  alias pec="pe --color"
  alias pee="pet edit"
}

[[ -v commands[pier] ]]      &&  alias pi="pier-exec"
[[ -v commands[stylua] ]]    && alias stylua="stylua -c $XDG_CONFIG_HOME/stylua/stylua.toml"
[[ -v commands[coreutils] ]] && alias cu='coreutils'
# (( ${+commands[dua]} )) && alias ncdu='dua i'

# === configs ===================================================================
alias ezsh='$EDITOR $HOME/.zshenv'
alias eezsh='$EDITOR $ZDOTDIR/.zshenv'
alias nzsh='$EDITOR $ZDOTDIR/.zshrc'
alias azsh='$EDITOR $ZDOTDIR/zsh.d/*-aliases.zsh'
alias vzsh='$EDITOR $ZDOTDIR/zsh.d/*-export.zsh'
alias fzsh='$EDITOR $ZDOTDIR/zsh.d/*-functions.zsh'
alias czsh='$EDITOR $ZDOTDIR/zsh.d/*-completions.zsh'
alias bzsh='$EDITOR $ZDOTDIR/zsh.d/*-keybindings.zsh'
alias lzsh='$EDITOR $ZDOTDIR/zsh.d/*-lf.zsh'
alias gzsh='$EDITOR $ZDOTDIR/plugins/git.zsh'
alias ezmsg='$EDITOR $XDG_CONFIG_HOME/xzmsg/themes/default.xzt'
alias nvivid='$EDITOR $ZDOTDIR/zsh.d/vivid/filetypes.yml'

alias nbsh='$EDITOR $HOME/.bashrc'
alias ncsh='$EDITOR $HOME/.cshrc'
alias nalac='$EDITOR $XDG_CONFIG_HOME/alacritty/alacritty.yml'
alias nwez='$EDITOR $XDG_CONFIG_HOME/wezterm/wezterm.lua'

alias nx='$EDITOR $HOME/.xinitrc'
alias npoly='$EDITOR $XDG_CONFIG_HOME/polybar/config.ini'
alias npicom='$EDITOR $XDG_CONFIG_HOME/picom/picom.conf'

alias ndunst='$EDITOR $XDG_CONFIG_HOME/dunst/dunstrc'
alias nssh='$EDITOR $HOME/.ssh/config'
alias ntmux='$EDITOR $XDG_CONFIG_HOME/tmux/tmux.conf'
alias ntmuxi='$EDITOR $XDG_CONFIG_HOME/tmuxinator/lwm.yml'
alias ntask='$EDITOR $XDG_CONFIG_HOME/task/taskrc'
alias nlfr='$EDITOR $XDG_CONFIG_HOME/lf/lfrc'
alias nlfrs='$EDITOR $XDG_CONFIG_HOME/lf/scope'
alias nxplr='$EDITOR $XDG_CONFIG_HOME/xplr/init.lua'
alias nw3m='$EDITOR $HOME/.w3m/keymap'
alias ngit='$EDITOR $XDG_CONFIG_HOME/git/config'
# alias ntig='$EDITOR $TIGRC_USER'
alias ntig='$EDITOR $XDG_CONFIG_HOME/tig/config'
alias nctags='$EDITOR $XDG_CONFIG_HOME/ctags/default.ctags'
alias nrofi='$EDITOR $XDG_CONFIG_HOME/rofi/config.rasi'
alias nmpc='$EDITOR $XDG_CONFIG_HOME/mpd/mpd.conf'
alias nncm='$EDITOR $XDG_CONFIG_HOME/ncmpcpp/bindings'
alias nurls='$EDITOR $XDG_CONFIG_HOME/newsboat/urls'
alias nnews='$EDITOR $XDG_CONFIG_HOME/newsboat/config'
alias nafew='$EDITOR $XDG_CONFIG_HOME/afew/config'
alias nzath='$EDITOR $XDG_CONFIG_HOME/zathura/zathurarc'
alias nmutt='$EDITOR $XDG_CONFIG_HOME/mutt/muttrc'
alias nmuch='$EDITOR $XDG_DATA_HOME/mail/.notmuch/hooks/post-new'

alias nticker='$EDITOR $XDG_CONFIG_HOME/ticker/ticker.yaml'
alias njaime='$EDITOR $XDG_CONFIG_HOME/jaime/config.yml'

alias nnvi='$EDITOR $NVIMRC'
alias nvi='$EDITOR $MYVIMRC'
alias nsnip='$EDITOR $XDG_CONFIG_HOME/nvim/UltiSnips/all.snippets'
alias ncoc='$EDITOR $XDG_CONFIG_HOME/nvim/coc-settings.json'
alias ninitv='vim $XDG_CONFIG_HOME/nvim/init.lua'
alias ninitp='pvim $XDG_CONFIG_HOME/nvim/init.lua'
alias ninit='$EDITOR $XDG_CONFIG_HOME/nvim/init.lua'
# alias niniti='$EDITOR $XDG_CONFIG_HOME/nvim/vimscript/plug.vim +PlugInstall'
# alias ninitu='$EDITOR $XDG_CONFIG_HOME/nvim/vimscript/plug.vim +PlugUpdate'
# alias ninitc='$EDITOR $XDG_CONFIG_HOME/nvim/vimscript/plug.vim +PlugClean'
# alias

(( ABSD )) && {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/yabai/yabairc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/skhd/skhdrc'
} || {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/bspwm/bspwmrc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/sxhkd/sxhkdrc'
  alias nskhdh='$EDITOR $XDG_CONFIG_HOME/sxhkd/mappings'
}

# === locations ==================================================================
# don't really use these anymore
alias prd='cd $HOME/projects'
alias unx='cd $HOME/Desktop/unix/mac'
alias zshd='cd $ZDOTDIR/zsh.d'
alias fzshd='cd $ZDOTDIR/functions'
alias czshd='cd $ZDOTDIR/completions'
alias zd='cd "$ZDOTDIR"'
alias zcs='cd $ZDOTDIR/csnippets'
alias gitd='cd $HOME/projects/github'
alias perld='cd $HOME/projects/perl'
alias perlb='cd $HOME/mybin/perl'
alias pyd='cd $HOME/projects/python'
alias awkd='cd $HOME/projects/awk'
alias optd='cd $HOME/opt'
alias confd='cd $XDG_CONFIG_HOME'
alias dotd='cd $HOME/opt/dotfiles'
alias locld='cd $XDG_DATA_HOME'
alias docd='cd $HOME/Documents'
alias cvd='cd $HOME/Documents/cv'
alias downd='cd $HOME/Downloads'
alias mbd='cd $HOME/mybin'
alias vwdir='cd $HOME/Documents/wiki/vimwiki'
alias nvimd='cd $GHQ_ROOT/github.com/neovim/neovim'

# ═══ Sourcing ═════════════════════════════════════════════════════════════════
alias srct='tmux source $XDG_CONFIG_HOME/tmux/tmux.conf'
alias srce='source $HOME/.zshenv'
alias srcp='source $ZDOTDIR/themes/p10k-post.zsh'

# === mail ======================================================================
(( ${+commands[mw]} )) && {
  alias mwme='mw -y burnsac@me.com'
  alias mwa='mw -Y'
}

# alias nmm="/usr/bin/nm"
alias nm="notmuch"
alias nh="notmuch"
alias nhls="nh search --output=tags '*'"

# === internet / vpn / etc ======================================================
# alias b='buku --suggest --colors gMclo'
alias b='buku --suggest --colors cJelo'
alias bw='b -w'
alias dl='aria2c -x 4 --dir="${HOME}/Downloads/Aria"'
alias dlpaste='aria2c "$(pbpaste)"'
# alias toilet='toilet -d /usr/local/figlet/2.2.5/share/figlet/fonts'
alias downl='xh --download'
alias googler='googler --colors bjdxxy'

alias wget='wget --hsts-file $XDG_CONFIG_HOME/wget/.wget-hsts'
# alias tsm='transmission-remote'
alias tsmd='transmission-daemon'
alias qbt='qbt torrent'

alias checkrootkits="sudo rkhunter --update; sudo rkhunter --propupd; sudo rkhunter --check"
alias checkvirus="clamscan --recursive=yes --infected $HOME/"
alias updateantivirus="sudo freshclam"

# === wiki ======================================================================
alias vw='$EDITOR $HOME/Documents/wiki/vimwiki/_index.md'
alias vwd='$EDITOR $HOME/Documents/wiki/vimwiki/code/dotfiles/_index.md'
alias vwl='$EDITOR $HOME/Documents/wiki/vimwiki/code/languages/_index.md'
alias vwz='$EDITOR $HOME/Documents/wiki/vimwiki/code/languages/zsh/_index.md'
alias vwL='$EDITOR $HOME/Documents/wiki/vimwiki/code/linux/_index.md'
alias vwc='$EDITOR $HOME/Documents/wiki/vimwiki/code/linux/programs.md'
alias vwm='$EDITOR $HOME/Documents/wiki/vimwiki/code/linux/manpages.md'
alias vwb='$EDITOR $HOME/Documents/wiki/vimwiki/code/browser/_index.md'
alias vwt='$EDITOR $HOME/Documents/wiki/vimwiki/list/todos.md'
alias vwB='$EDITOR $HOME/Documents/wiki/vimwiki/writing/blog/_index.md'
# alias vwo='$EDITOR $HOME/Documents/wiki/vimwiki/other/index.md'

# === github ====================================================================
alias tigdb="GIT_DIR=$DOTBARE_DIR GIT_WORK_TREE=$DOTBARE_TREE tig"
alias dtig="GIT_DIR=$DOTBARE_DIR GIT_WORK_TREE=$DOTBARE_TREE tig"
alias h='git'
alias g='hub'

alias conf='/usr/bin/git --git-dir=$XDG_DATA_HOME/dotfiles-private --work-tree=$HOME'
alias xav='/usr/bin/git --git-dir=$XDG_DATA_HOME/dottest --work-tree=$HOME'

alias gitreset='mgit reset --hard HEAD && mgit clean -fd && mgit pull'

alias gua='git remote | xargs -L1 git push --all'
alias grmssh='ssh git@lmburns.com -- grm'
alias hubb='hub browse $(ghq list | fzf --prompt "hub> " --height 40% --reverse | cut -d "/" -f 2,3)'
alias gtrr='git ls-tree -r master --name-only | as-tree'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias ngc='$EDITOR $(git rev-parse --show-toplevel)/.git/config'
alias lgd='lg --git-dir=$XDG_DATA_HOME/dotfiles --work-tree=$HOME'

(( ${+commands[gitbatch]} )) && {
  alias gball='gitbatch -r 2 -d "$HOME/opt"'
  alias gbghq='gitbatch -r 3 -d "$HOME/ghq"'
  alias gbzin='gitbatch -r 2 -d "$ZINIT_HOME/plugins"'
}

# === Fixes =====================================================================
alias gdl='gallery-dl'
alias thumbs='thumbsup --input ./img --output ./gallery --title "images" --theme cards --theme-style style.css && rsync -av gallery root@lmburns.com:/var/www/lmburns'

alias tornew="echo -e 'AUTHENTICATE \"\"\r\nsignal NEWNYM\r\nQUIT' | nc 127.0.0.1 9051"
alias speedt='speedtest | rg "(Download:|Upload:)"'
alias essh='eval $(ssh-add)'
alias kc='keychain'
alias kcl='keychain -l'
alias kck='keychain -k all'
alias gpgkill='gpgconf --kill all'
alias gpg-tui='gpg-tui --style colored -c 98676A'
alias mpd='mpd $XDG_CONFIG_HOME/mpd/mpd.conf'
alias hangups='hangups -c $XDG_CONFIG_HOME/hangups/hangups.conf'
alias newsboat='newsboat -C $XDG_CONFIG_HOME/newsboat/config'
alias podboat='podboat -C $XDG_CONFIG_HOME/newsboat/config'
alias ticker='ticker --config $XDG_CONFIG_HOME/ticker/ticker.yaml'
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
alias abook='abook --config "$XDG_CONFIG_HOME/abook/abookrc" --datafile "$XDG_CONFI_HOME/abook/addressbook"'
alias irssi="irssi --home ${XDG_CONFIG_HOME}/irssi",
alias monerod="monerod --data-dir ${XDG_DATA_HOME}/bitmonero"
# alias mbsync="mbsync -c ${XDG_CONFIG_HOME}/isync/mbsyncrc",
# alias mbsync='mbsync -c $MBSYNCRC'

alias ume='um edit'

alias tt='taskwarrior-tui'
alias t='task'
alias te='task edit'
alias taske='task edit'
alias th='threadwatcher'
alias tha='threadwatcher add'

alias jrnlw='jrnl wiki'
# alias nb='BROWSER=w3m nb'
# alias jrnl='jrnl'

alias cat='bat'
alias batp='bat --paging=always'
alias batpp='bat -p --paging=always'
alias gat='bat --style=rule,changes'
alias pat='bat --style=rule'
alias hat='bat --style=header'
alias duso='du -hsx * | sort -rh | bat --paging=always'

alias tm='tmsu'
alias ja="jaime"
alias xx="xcompress"
alias ca='cargo'
alias dic='trans -d'
alias thw="the-way"
alias mmtc='mmtc -c "$XDG_CONFIG_HOME/mmtc/config.ron"'
alias getcert='openssl s_client -connect'
alias yt='yt-dlp --add-metadata -i'
alias ctrim='par -vun "cd {} && cargo trim clear" ::: $(fd -td -d1)'
alias fehh='feh --scale-down --auto-zoom --borderless --image-bg black --draw-filename'

# alias passver="veracrypt --text --keyfiles ~/.password.vera.key --pim=0 --protect-hidden=no --mount ~/.password.vera ~/.local/share/password-store"
# alias passverr="veracrypt --text --dismount ~/.password.vera"

(( $+commands[rlwrap] )) && {
  alias perlr="rlwrap -Ar -pblue -S'perl> ' perl -wnE'say eval()//\$@'"
  alias luar="rlwrap -Ar -ppurple --always-readline lua"
  alias luajitr="rlwrap -Ar -ppurple --always-readline luajit"
}

(( ${+commands[tldr]} )) && alias tldru='tldr --update'
(( ${+commands[assh]} )) && alias hssh="assh wrapper ssh"

# === Command Managers ==========================================================
(( ${+commands[pueue]} )) && {
  alias pu='pueue'
  alias pud='pueued -dc "$XDG_CONFIG_HOME/pueue/pueue.yml"'
}

alias .ts='TS_SOCKET=/tmp/ts1 tsp'
alias .nq='NQDIR=/tmp/nq1 nq'
alias .fq='NQDIR=/tmp/nq1 fq'
alias .fnq='FNQDIR=/tmp/fnq1 fnq'

alias getmime='file --dereference --brief --mime-type'
alias zath='zathura'
alias n='man'

alias mux="tmuxinator"
alias tn='tmux new-session -s'
alias tll='tmux list-sessions'
alias tmuxls="ls $TMPDIR/tmux*/"

alias mycli='LESS="-S $LESS" mycli'
alias litecli='LESS="-S $LESS" litecli'

(( ${+commands[pacaptr]} )) && {
  alias tlm='pacaptr --using tlmgr'
  alias pipp='pacaptr --using pip'
}

(( ${+commands[paru]} )) && {
  alias p="paru"
  alias pn="paru --noconfirm"
}

# === trash =====================================================================
(( ${+commands[rip]} )) && alias rr="rip"

(( ${+commands[trash-put]} )) && {
  alias rrr='trash-put'
  alias tre='trash-empty'
  alias trl='trash-list'
  alias trr='trash-restore'
  alias trm='trash-rm'
}

# === rsync =====================================================================
(( $+commands[rsync] )) && {
  alias rcp='rsync -av --ignore-existing --progress'
  alias rsyn='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS'

  alias rsynca='rsync -Pyuazv --info=progress2 --name=name0 --delete-after --exclude ".DS_Store" --exclude ".ipynb_checkpoints"'

  alias rsyncsrv='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after \
    --exclude "/boot/*" \
    --exclude "/dev/*" --exclude "/proc/*" --exclude "/sys/*" --exclude "/tmp/*" \
    --exclude "/run/*" --exclude "/mnt/*" --exclude "/media/*" --exclude "**/swapfile" \
    --exclude "**/lost+found" root@lmburns.com:/ /home/lucas/server/backup/_full/'

  alias wwwpull='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after root@lmburns.com:/var/www $HOME/server'
  alias wwwpush='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after --exclude ".DS_Store" $HOME/server /run/media/lucas/SSD'
  alias sudorsync='sudo rsync -azurh --delete-after --include ".*" --exclude ".DS_Store" \
    --exclude ".ipynb_checkpoints" --exclude "/run/media/lucas/*" --exclude "/cores/*" / /run/media/lucas/SSD/server-full'
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
