############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# Giving item its' full path
# alias tlmgr="/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode"
# alias mail='/usr/bin/mail'
# alias strace="/usr/local/bin/strace"

# alias xevk="xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'"

alias -g W="!"
alias -g G='| rg '      H='| head '      T='| tail '
alias -g B='| bat '     S='| sort '      U='| uniq '
alias -g CW='| cw'      RE='| tac '      F='| fzf'
alias -g N='>/dev/null' NN='&>/dev/null' 2N='2>/dev/null '
alias -g NN="*(oc[1])"  NNF="*(oc[1].)"  NND="*(oc[1]/)" # inode change
alias -g AN="*(oa[1])"  ANF="*(oa[1].)"  AND="*(oa[1]/)" # access time
alias -g MN='*(om[1])'  MNF='*(om[1].)'  MND='*(om[1]/)' # modification time

alias {\$,%}=

alias RGV='RG -g "*.lua" -g "*.vim"'
alias RGL='RG -g "*.lua"'
alias sane='stty sane'
alias nd='neovide'
alias tm='tmsu'
alias ja="jaime"
# alias xq="$PYENV_ROOT/shims/yq"
alias xp="xplr"
alias xx="xcompress"
alias ca='cargo'
alias cat="bat"
alias thw="the-way"
alias mmtc='mmtc -c "$XDG_CONFIG_HOME/mmtc/config.ron"'
alias getcert='openssl s_client -connect'

alias akill='/home/lucas/.local/share/npm-packages/bin/fkill'
alias open="handlr open"
alias jor="journalctl"
alias jortoday="journalctl -xe --since=today"
alias xmm="xmodmap"
alias s="systemctl"
alias bctl="bluetoothctl"
alias plast="last -20"

alias fehh='feh \
           --scale-down \
           --auto-zoom \
           --borderless \
           --image-bg black \
           --draw-filename'

alias passver="veracrypt --text --keyfiles ~/.password.vera.key --pim=0 --protect-hidden=no --mount ~/.password.vera ~/.local/share/password-store"
alias passverr="veracrypt --text --dismount ~/.password.vera"

alias ctrim='par -vun "cd {} && cargo trim clear" ::: $(fd -td -d1)'
alias :q='exit'

(( ${+commands[surfraw]} )) && {
  # alias srg='surfraw -browser=$BROWSER'
  alias srg='sr -g'
  alias srh='srg github'
  alias srl='BROWSER=$BROWSERCLI sr'
  alias srb='BROWSER=brave srg'
  alias srgg='BROWSER=$BROWSER srg google'
}

(( ${+commands[xidlehook]} )) && {
  alias xidlestop="xidlehook-client --socket /tmp/xidlehook.sock reset-idle"
  alias xidlered="xidlehook-client --socket /tmp/xidlehook.sock control --action Disable --timer 0"
}

(( ${+commands[stylua]} )) && alias stylua="stylua -c $XDG_CONFIG_HOME/stylua/stylua.toml"

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

(( ${+commands[pet]} )) && {
  # Doesn't run
  alias pe="pet exec"
  alias pec="pe --color"
  alias pee="pet edit"
}

(( ${+commands[pier]} )) && {
  alias pi="pier-exec"
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

# === zsh-help ==============================================================
alias lynx="lynx -vikeys -accept-all-cookies"

# === general ===================================================================
# alias sudo='doas'
# alias sudo='sudo '
alias usudo='sudo -E -s '
alias _='sudo'
# alias s='sudo'
alias __='doas'
# alias mkd='mkdir -pv'

(( ${+commands[exa]} )) && {
  # --ignore-glob=".DS_Store|__*
  alias l='exa -FHb --git --icons'
  alias lp='exa -1F'
  alias ll='exa -FlahHgb --git --icons --time-style long-iso --octal-permissions'
  alias ls='exa -Fhb --git --icons'
  alias lsd='ls -d'
  alias lse='exa -Flhb --git --sort=extension --icons'
  # Reverse
  alias llr='exa -FlahHgb --git --icons --time-style long-iso --octal-permissions --reverse'
  # Sort by modified
  alias lsm='exa -Flhb --git --sort=modified --modified --icons'
  # 10 oldest files
  alias lsfo='lsm *(D.Om[1,10])'
  # 10 newest files
  alias lsfn='lsm *(D.om[1,10])'
  # Sort by size
  alias lsz='exa -Flhb --git --sort=size --icons'
  # 10 biggest files
  alias lsbig='lsz *(.OL[1,10])'
  # 10 smallest files
  alias lssmall='lsz *(.oL[1,10])'

  alias lss='exa -Flhb --git --group-directories-first --icons'

  alias lsD='exa -D --icons --git'
  alias lsDl='ll -D'
  # 10 newest directories
  alias lsdn='ll -d --sort=modified -- *(/om[1,10])'
  # Empty directories
  alias lsde='ll -d -- *(/^F)'

  # Setgid/setuid/sticky flag
  alias lssticky='ll -- *(s,S,t)'
  # Executables
  alias lsx='ll -- *(*)'
  # Symlinks
  alias lssym='ll -d -- *(@N)'

  alias tree='exa --icons --git -TL'
  alias lt='tree 1 -@'
  alias ls@='exa -FlaHb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  alias lsb='exa -FlaHBb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  # alias lm='exa -l  --no-user --no-permissions --no-time -@'

  # Dotfiles
  alias l.='exa -FHb --git --icons -d .*(.)'
  alias ls.='ll -d -- .*(.)'
}

(( ${+commands[fd]} )) && {
  alias fd='fd -Hi'
  alias fdg='fd --glob'
  alias fdc='fd --color=always'
  alias fdr='fd --changed-within=20m -d1' # 'recent'
  alias fdrd='fd --changed-within=30m'    # 'recent, depth'
  alias fdrr='fd --changed-within=1m'     # 'really recent'
}

alias pl='print -rl --'
alias pp='print -Pr --'
alias pz='print -Pl --'
alias plm='pl $match[@]'
alias plM='pl $MATCH'
alias plr='pl $reply[@]'
alias plR='pl $REPLY'
alias ret='pp "%F{%(?,10,9)}%B%(?,0,1)%b%f"'
# alias ret='pp ${?//(#m)*/${${${(M)MATCH:#0}:+$fg_bold[green]0}:-$fg_bold[red]$MATCH}}'

alias zstats='zstat -sF "%b %e %H:%M:%S"'
alias ngl="noglob"

alias chx='chmod ug+x'
alias chmx='chmod -x'
alias cp='command cp -ivp'
alias cpxattr='command cp -ivp --preserve=xattr'
alias mv='command mv -iv'
alias lns='command ln -siv'
alias kall='killall'
alias kid='kill -KILL'
alias yt='yt-dlp --add-metadata -i'
alias grep="command grep --color=auto --binary-files=without-match --directories=skip"
alias prg="rg --pcre2"
alias frg="rg -F"
alias irg="rg --no-ignore"
alias diff='diff --color=auto'
alias sha='shasum -a 256'
alias wh="whence -f"
alias wa="whence -va" # where
alias wm="whence -vm"
alias info='info --vi-keys'

# [[ -n "$NVIM_LISTEN_ADDRESS" ]] && alias nvim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
alias pvim='nvim -u NONE'
alias vi="$EDITOR"
alias svi="sudo $EDITOR"
#alias vim='/usr/bin/vim'
alias vimdiff='nvim -d'

# alias f='pushd'
# alias b='popd'
# alias dirs='dirs -v'

# (( ${+commands[dua]} )) && alias ncdu='dua i'
(( ${+commands[coreutils]} )) && alias cu='coreutils'

# === configs ===================================================================
alias npoly='$EDITOR $XDG_CONFIG_HOME/polybar/config'
alias nx='$EDITOR $HOME/.xinitrc'

alias ndunst='$EDITOR $XDG_CONFIG_HOME/dunst/dunstrc'
alias npicom='$EDITOR $XDG_CONFIG_HOME/picom/picom.conf'
alias nrofi='$EDITOR $XDG_CONFIG_HOME/rofi/config.rasi'
alias nalac='$EDITOR $XDG_CONFIG_HOME/alacritty/alacritty.yml'
alias nwez='$EDITOR $XDG_CONFIG_HOME/wezterm/wezterm.lua'
alias nprof='$EDITOR $HOME/.profile'
alias nzsh='$EDITOR $ZDOTDIR/.zshrc'
alias azsh='$EDITOR $ZDOTDIR/zsh.d/aliases.zsh'
alias lzsh='$EDITOR $ZDOTDIR/zsh.d/lficons.zsh'
alias fzsh='$EDITOR $ZDOTDIR/zsh.d/functions.zsh'
alias czsh='$EDITOR $ZDOTDIR/zsh.d/completions.zsh'
alias bzsh='$EDITOR $ZDOTDIR/zsh.d/keybindings.zsh'
alias ndir='$EDITOR $ZDOTDIR/gruv.dircolors'
alias ezsh='$EDITOR $HOME/.zshenv'
alias ncoc='$EDITOR $XDG_CONFIG_HOME/nvim/coc-settings.json'
alias ntask='$EDITOR $XDG_CONFIG_HOME/task/taskrc'
alias nlfr='$EDITOR $XDG_CONFIG_HOME/lf/lfrc'
alias nlfrs='$EDITOR $XDG_CONFIG_HOME/lf/scope'
alias nxplr='$EDITOR $XDG_CONFIG_HOME/xplr/init.lua'
alias ngit='$EDITOR $XDG_CONFIG_HOME/git/config'
alias nurls='$EDITOR $XDG_CONFIG_HOME/newsboat/urls'
alias nnews='$EDITOR $XDG_CONFIG_HOME/newsboat/config'
alias nw3m='$EDITOR $HOME/.w3m/keymap'
alias ntig='$EDITOR $TIGRC_USER'
alias nmpc='$EDITOR $XDG_CONFIG_HOME/mpd/mpd.conf'
alias nncm='$EDITOR $XDG_CONFIG_HOME/ncmpcpp/bindings'
alias nmutt='$EDITOR $XDG_CONFIG_HOME/mutt/muttrc'
alias nmuch='$EDITOR $XDG_DATA_HOME/mail/.notmuch/hooks/post-new'
alias nsnip='$EDITOR $XDG_CONFIG_HOME/nvim/UltiSnips/all.snippets'
alias nticker='$EDITOR $XDG_CONFIG_HOME/ticker/ticker.yaml'
alias njaime='$EDITOR $XDG_CONFIG_HOME/jaime/config.yml'
alias nssh='$EDITOR $HOME/.ssh/config'
alias ntmux='$EDITOR $XDG_CONFIG_HOME/tmux/tmux.conf'
alias ntmuxi='$EDITOR $XDG_CONFIG_HOME/tmuxinator/lwm.yml'
alias nvivid='$EDITOR $ZDOTDIR/zsh.d/vivid/filetypes.yml'

alias ninitv='/usr/bin/vim $XDG_CONFIG_HOME/nvim/init.lua'
alias ninitp='pvim $XDG_CONFIG_HOME/nvim/init.lua'
alias ninit='$EDITOR $XDG_CONFIG_HOME/nvim/init.lua'
# alias niniti='$EDITOR $XDG_CONFIG_HOME/nvim/vimscript/plug.vim +PlugInstall'
# alias ninitu='$EDITOR $XDG_CONFIG_HOME/nvim/vimscript/plug.vim +PlugUpdate'
# alias ninitc='$EDITOR $XDG_CONFIG_HOME/nvim/vimscript/plug.vim +PlugClean'
# alias

[[ $OSTYPE = darwin* ]] && {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/yabai/yabairc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/skhd/skhdrc'
} || {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/bspwm/bspwmrc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/sxhkd/sxhkdrc'
  alias nskhdh='$EDITOR $XDG_CONFIG_HOME/sxhkd/mappings'
}

# ═══ Sourcing ═════════════════════════════════════════════════════════════════
alias srct='tmux source $XDG_CONFIG_HOME/tmux/tmux.conf'
alias srce='source $HOME/.zshenv'
alias srcp='source $ZDOTDIR/themes/p10k-post.zsh'

# === mail ======================================================================
(( ${+commands[mw]} )) && {
  alias mwme='mw -y burnsac@me.com'
  alias mwa='mw -Y'
}

alias nmm="/usr/bin/nm" # I don't use this program
alias nm="notmuch"
alias nmls="nm search --output=tags '*'"

# === locations ==================================================================
alias prd='cd $HOME/projects'
alias unx='cd $HOME/Desktop/unix/mac'
alias zshd='cd $ZDOTDIR/zsh.d'
alias zfd='cd $ZDOTDIR/functions'
alias zcs='cd $ZDOTDIR/csnippets'
alias zcm='cd $ZDOTDIR/completions'
alias zd='cd "$ZDOTDIR"'
alias gitd='cd $HOME/projects/github'
alias perld='cd $HOME/projects/perl'
alias perlb='cd $HOME/mybin/perl'
alias pyd='cd $HOME/projects/python'
alias awkd='cd $HOME/projects/awk'
alias optd='cd $HOME/opt'
alias confd='cd $XDG_CONFIG_HOME'
alias dotd='cd $HOME/opt/dotfiles'
alias locd='cd $XDG_DATA_HOME'
alias docd='cd $HOME/Documents'
alias cvd='cd $HOME/Documents/cv'
alias downd='cd $HOME/Downloads'
alias mbd='cd $HOME/mybin'
alias vwdir='cd $HOME/vimwiki'
alias nvimd='cd /usr/local/share/nvim/runtime'

# === internet / vpn / etc ======================================================
# alias b='buku --suggest --colors gMclo'
alias b='buku --suggest --colors cJelo'
alias dl='aria2c -x 4 --dir="${HOME}/Downloads/Aria"'
alias dlpaste='aria2c "$(pbpaste)"'
# alias toilet='toilet -d /usr/local/figlet/2.2.5/share/figlet/fonts'
alias downl='xh --download'
alias googler='googler --colors bjdxxy'

alias wget='wget --hsts-file $XDG_CONFIG_HOME/wget/.wget-hsts'
alias tsm='transmission-remote'
alias tsmd='transmission-daemon'
alias qbt='qbt torrent'

alias speedt='speedtest | rg "(Download:|Upload:)"'
alias essh='eval $(ssh-add)'
alias kc='keychain'
alias kcl='keychain -l'
alias kck='keychain -k all'

alias checkrootkits="sudo rkhunter --update; sudo rkhunter --propupd; sudo rkhunter --check"
alias checkvirus="clamscan --recursive=yes --infected $HOME/"
alias updateantivirus="sudo freshclam"

# === wiki ======================================================================
alias vw='$EDITOR $HOME/vimwiki/index.md'
alias vwd='$EDITOR $HOME/vimwiki/dotfiles/index.md'
alias vws='$EDITOR $HOME/vimwiki/scripting/index.md'
alias vwb='$EDITOR $HOME/vimwiki/blog/index.md'
alias vwl='$EDITOR $HOME/vimwiki/languages/index.md'
alias vwL='$EDITOR $HOME/vimwiki/linux/index.md'
alias vwc='$EDITOR $HOME/vimwiki/linux/programs.md'
alias vwo='$EDITOR $HOME/vimwiki/other/index.md'
alias vwt='$EDITOR $HOME/vimwiki/todos.md'

# === github ====================================================================
alias h='git'
alias g='hub'

alias conf='/usr/bin/git --git-dir=$XDG_DATA_HOME/dotfiles-private --work-tree=$HOME'
alias xav='/usr/bin/git --git-dir=$XDG_DATA_HOME/dottest --work-tree=$HOME'

alias resetgit='mgit reset --hard HEAD && mgit clean -fd && mgit pull'

alias gua='git remote | xargs -L1 git push --all'
alias grmssh='ssh git@lmburns.com -- grm'
alias hubb='hub browse $(ghq list | fzf --prompt "hub> " --height 40% --reverse | cut -d "/" -f 2,3)'
alias gtrr='git ls-tree -r master --name-only | as-tree'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

alias magit='nvim -c MagitOnly'
alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias ngc='$EDITOR $(git rev-parse --show-toplevel)/.git/config'
alias lgd='lg --git-dir=$XDG_DATA_HOME/dotfiles --work-tree=$HOME'

(( ${+commands[gitbatch]} )) && {
  alias gball='gitbatch -r 2 -d "$HOME/opt"'
  alias gbghq='gitbatch -r 3 -d "$HOME/ghq"'
  alias gbzin='gitbatch -r 2 -d "$ZINIT_HOME/plugins"'
}

# === Fixes =====================================================================
alias thumbs='thumbsup --input ./img --output ./gallery --title "images" --theme cards --theme-style style.css && rsync -av gallery root@lmburns.com:/var/www/lmburns'

alias tornew="echo -e 'AUTHENTICATE \"\"\r\nsignal NEWNYM\r\nQUIT' | nc 127.0.0.1 9051"
alias gpgkill='gpgconf --kill all'
alias gpg-tui='gpg-tui --style colored -c 98676A'
alias mpd='mpd $XDG_CONFIG_HOME/mpd/mpd.conf'
alias hangups='hangups -c $XDG_CONFIG_HOME/hangups/hangups.conf'
alias newsboat='newsboat -C $XDG_CONFIG_HOME/newsboat/config'
alias podboat='podboat -C $XDG_CONFIG_HOME/newsboat/config'
alias ticker='ticker --config $XDG_CONFIG_HOME/ticker/ticker.yaml'
alias abook='abook --config "$XDG_CONFIG_HOME"/abook/abookrc --datafile "$XDG_DATA_HOME"/abook/addressbook'
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
# alias mbsync='mbsync -c $MBSYNCRC'

alias ume='um edit'

alias tt="taskwarrior-tui"
alias t="task"
alias te='t edit'
alias taske='t edit'

# xclip -in -selection clipboard -rmlastnl
# xclip -out -selection clipboard
alias pbcopy="xsel --clipboard --input --trim"
alias pbpaste="xsel --clipboard --output"
alias pbc='pbcopy'
alias pbp='pbpaste'

alias lsf='lsof -w'
alias lsfp='lsof -w -p'

alias vmst='vmstat -SM 1'
alias iost='iostat -y -d -h -t 1'

alias jrnlw='jrnl wiki'
alias nb='BROWSER=w3m nb'
# alias jrnl='jrnl'

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

# alias sr='sr -browser=w3m'
# alias srg='sr -browser="$BROWSER"'

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
  alias tlm='p --using tlmgr'
  alias pipp='p --using pip'
}

(( ${+commands[paru]} )) && {
  alias p="paru"
  alias pn="paru --noconfirm"
}

alias pat='bat --style=snip'
alias hat='bat --style=header'
alias duso='du -hsx * | sort -rh | bat --paging=always'

alias dic='trans -d'

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

  # Prugoptczl
  alias rsyncsrv='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after --exclude "/dev/*" --exclude "/proc/*" --exclude "/sys/*" --exclude "/tmp/*" \
    --exclude "/run/*" --exclude "/mnt/*" --exclude "/media/*" --exclude "swapfile" \
    --exclude "lost+found" root@lmburns.com:/ /run/media/lucas/exfat/server-full'

  # rugoptczl --info=progress2 --info=name0
  alias wwwpull='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after root@lmburns.com:/var/www $HOME/server'
  alias wwwpush='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after --exclude ".DS_Store" $HOME/server /run/media/lucas/SSD'
  alias sudorsync='sudo rsync -azurh --delete-after --include ".*" --exclude ".DS_Store" \
    --exclude ".ipynb_checkpoints" --exclude "/run/media/lucas/*" --exclude "/cores/*" / /run/media/lucas/SSD/server-full'
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
