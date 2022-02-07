############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# alias xevk="xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'"

alias -g G='| rg '
alias -g H='| head'
alias -g T='| tail'
alias -g B='| bat'

alias %= \$=

# alias tlmgr="/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode"
alias nd='neovide'
alias tm='tmsu'
alias mail='/usr/bin/mail'
alias ja="jaime"
# alias xq="$PYENV_ROOT/shims/yq"
alias xp="xplr"
alias xx="xcompress"
alias ca='cargo'
alias cat="bat"
alias thw="the-way"
alias mmtc='mmtc -c "$XDG_CONFIG_HOME/mmtc/config.ron"'
alias tt="taskwarrior-tui"
alias strace="/usr/local/bin/strace"

alias akill='/home/lucas/.local/share/npm-packages/bin/fkill'
alias open="handlr open"
# alias mimeopen="/home/lucas/mybin/perl/mimeopen"
alias jor="journalctl"
alias xmm="xmodmap"
alias s="systemctl"
alias bctl="bluetoothctl"

alias feh='feh \
           --scale-down \
           --auto-zoom \
           --borderless \
           --image-bg black \
           --draw-filename \
           --draw-tinted \
           --keep-zoom-vp \
           --conversion-timeout 1'

alias passver="veracrypt --text --keyfiles ~/.password.vera.key --pim=0 --protect-hidden=no --mount ~/.password.vera ~/.local/share/password-store"
alias passverr="veracrypt --text --dismount ~/.password.vera"

alias zstats='zstat -sF "%b %e %H:%M:%S"'
alias ctrim='par -vun "cd {} && cargo trim clear" ::: $(fd -td -d1)'
alias :q='exit'
alias ng="noglob"

(( ${+commands[surfraw]} )) && {
  # alias srg='surfraw -browser=$BROWSER'
  alias srg='sr -g'
  alias srh='srg github'
  alias srb='surfraw -browser=$BROWSERCLI'
  alias srr='surfraw -browser=brave'
  alias srgg='surfraw -browser=$BROWSER google'
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
alias cp='/bin/cp -ivp'
alias pl='print -rl --'
alias pp='print -Pr --'
alias mv='mv -iv'
# alias mkd='mkdir -pv'

(( ${+commands[exa]} )) && {
  # --ignore-glob=".DS_Store|__*
  alias l='exa -FHb --git --icons'
  alias l.='exa -FHb --git --icons -d .*'
  alias lp='exa -1F'
  alias ll='exa -FlahHgb --git --icons --time-style long-iso --octal-permissions'
  alias ls='exa -Fhb --git --icons'
  alias lse='exa -Flhb --git --sort=extension --icons'
  alias lsm='exa -Flhb --git --sort=modified --icons'
  alias lsz='exa -Flhb --git --sort=size --icons'
  alias lss='exa -Flhb --git --group-directories-first --icons'
  alias lsd='exa -D --icons --git'
  alias tree='exa --icons --git -TL'
  alias lm='tree 1 -@'
  alias ls@='exa -FlaHb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  alias lsb='exa -FlaHBb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  # alias lm='exa -l  --no-user --no-permissions --no-time -@'
}

(( ${+commands[fd]} )) && {
  alias fd='fd -Hi'
  alias fdc='fd --color=always'
  alias fdr='fd --changed-within=20m -d1'
  alias fdrd='fd --changed-within=30m'
  alias fdrr='fd --changed-within=1m'
}

alias chx='chmod ug+x'
alias chmx='chmod -x'
alias lns='ln -siv'
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
alias wa="whence -va"
alias wm="whence -m"

alias pvim='nvim -u NONE'

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
alias nprof='$EDITOR $HOME/.profile'
alias nzsh='$EDITOR $ZDOTDIR/.zshrc'
alias azsh='$EDITOR $ZDOTDIR/zsh.d/aliases.zsh'
alias bzsh='$EDITOR $ZDOTDIR/zsh.d/keybindings.zsh'
alias ndir='$EDITOR $ZDOTDIR/gruv.dircolors'
alias ezsh='$EDITOR $HOME/.zshenv'
alias ncoc='$EDITOR $XDG_CONFIG_HOME/nvim/coc-settings.json'
alias ninitv='/usr/bin/vim $XDG_CONFIG_HOME/nvim/init.vim'
alias ninitp='pvim $XDG_CONFIG_HOME/nvim/init.vim'
alias ninit='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim'
alias niniti='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim +PlugInstall'
alias ninitu='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim +PlugUpdate'
alias ntask='$EDITOR $XDG_CONFIG_HOME/task/taskrc'
alias nlfr='$EDITOR $XDG_CONFIG_HOME/lf/lfrc'
alias nlfrs='$EDITOR $XDG_CONFIG_HOME/lf/scope'
alias nxplr='$EDITOR $XDG_CONFIG_HOME/xplr/init.lua'
alias ngit='$EDITOR $XDG_CONFIG_HOME/git/config'
alias ntmux='$EDITOR $XDG_CONFIG_HOME/tmux/tmux.conf'
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

[[ $OSTYPE = darwin* ]] && {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/yabai/yabairc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/skhd/skhdrc'
} || {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/bspwm/bspwmrc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/sxhkd/sxhkdrc'
  alias nskhdh='$EDITOR $XDG_CONFIG_HOME/sxhkd/mappings'
}

alias srct='tmux source $XDG_CONFIG_HOME/tmux/tmux.conf'
alias srce='source $HOME/.zshenv'

# === mail ======================================================================
(( ${+commands[mw]} )) && {
  alias mwme='mw -y burnsac@me.com'
  alias mwa='mw -Y'
}

alias nm="notmuch"
alias nmls="nm search --output=tags '*'"

# ===locations ==================================================================
alias prd='cd $HOME/projects'
alias unx='cd $HOME/Desktop/unix/mac'
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
alias b='buku --suggest --colors gMclo'
alias dl='aria2c -x 4 --dir="${HOME}/Downloads/Aria"'
alias dlpaste='aria2c "$(pbpaste)"'
# alias toilet='toilet -d /usr/local/figlet/2.2.5/share/figlet/fonts'
alias downl='xh --download'
alias googler='googler --colors bjdxxy'

alias wget='wget --hsts-file $XDG_CONFIG_HOME/wget/.wget-hsts'
alias tsm='transmission-remote'
alias tsmd='transmission-daemon'
alias qbt='qbt torrent'

alias n1sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias n1httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias pyn='openpyn'
alias oconn='openpyn us -t 10'
alias speedt='speedtest | rg "(Download:|Upload:)"'
alias essh='eval $(ssh-add)'
alias kc='keychain'
alias kcl='keychain -l'
alias kck='keychain -k all'

# xclip -in -selection clipboard -rmlastnl
# xclip -out -selection clipboard
alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"
alias pbc='pbcopy'
alias pbp='pbpaste'

# === wiki ======================================================================
alias vw='$EDITOR $HOME/vimwiki/index.md'
alias vwd='$EDITOR $HOME/vimwiki/dotfiles/index.md'
alias vws='$EDITOR $HOME/vimwiki/scripting/index.md'
alias vwb='$EDITOR $HOME/vimwiki/blog/index.md'
alias vwl='$EDITOR $HOME/vimwiki/languages/index.md'
alias vwL='$EDITOR $HOME/vimwiki/linux/index.md'
alias vwc='$EDITOR $HOME/vimwiki/linux/programs.md'
alias vwo='$EDITOR $HOME/vimwiki/other/index.md'

# === github ====================================================================
alias conf='/usr/bin/git --git-dir=$XDG_DATA_HOME/dotfiles-private --work-tree=$HOME'
alias xav='/usr/bin/git --git-dir=$XDG_DATA_HOME/dottest --work-tree=$HOME'

alias lgd='lg --git-dir=$XDG_DATA_HOME/dotfiles --work-tree=$HOME'

alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias gua='git remote | xargs -L1 git push --all'
alias grmssh='ssh git@burnsac.xyz -- grm'
alias h='git'
alias g='hub'
alias hubb='hub browse $(ghq list | fzf --prompt "hub> " --height 40% --reverse | cut -d "/" -f 2,3)'
alias gtrr='git ls-tree -r master --name-only | as-tree'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

alias magit='nvim -c MagitOnly'
alias ngc='$EDITOR $(git rev-parse --show-toplevel)/.git/config'
alias nbconvert='jupyter nbconvert --to python'

(( ${+commands[gitbatch]} )) && {
  alias gball='gitbatch -r 2 -d "$HOME/opt"'
  alias gbghq='gitbatch -r 3 -d "$HOME/ghq"'
  alias gbzin='gitbatch -r 2 -d "$ZINIT_HOME/plugins"'
}

# === other =====================================================================
alias gpg-tui='gpg-tui --style colored -c 98676A'

alias thumbs='thumbsup --input ./img --output ./gallery --title "images" --theme cards --theme-style style.css && rsync -av gallery root@burnsac.xyz:/var/www/lmburns'

alias nerdfont='source $XDG_DATA_HOME/fonts/i_all.sh'

alias mpd='mpd ~/.config/mpd/mpd.conf'
alias hangups='hangups -c $XDG_CONFIG_HOME/hangups/hangups.conf'
alias newsboat='newsboat -C $XDG_CONFIG_HOME/newsboat/config'
alias podboat='podboat -C $XDG_CONFIG_HOME/newsboat/config'
alias ticker='ticker --config $XDG_CONFIG_HOME/ticker/ticker.yaml'
alias abook='abook --config "$XDG_CONFIG_HOME"/abook/abookrc --datafile "$XDG_DATA_HOME"/abook/addressbook'
# alias mbsync='mbsync -c $MBSYNCRC'
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
alias taske='task edit'
alias ume='um edit'

(( ${+commands[tldr]} )) && alias tldru='tldr --update'
(( ${+commands[assh]} )) && alias hssh="assh wrapper ssh"

(( ${+commands[pueue]} )) && {
  alias pu='pueue'
  alias pud='pueued -dc "$XDG_CONFIG_HOME/pueue/pueue.yml"'
}
alias .ts='TS_SOCKET=/tmp/ts1 tsp'
alias .nq='NQDIR=/tmp/nq1 nq'
alias .fq='NQDIR=/tmp/nq1 fq'

# alias sr='sr -browser=w3m'
# alias srg='sr -browser="$BROWSER"'

alias img='/usr/local/bin/imgcat'
alias getmime='file --dereference --brief --mime-type'
alias cleanzsh='sudo rm -rf /private/var/log/asl/*.asl'

alias zath='zathura'
alias n='man'
# alias n='gman'

alias tn='tmux new-session -s'
alias tl='tmux list-sessions'

alias mycli='LESS="-S $LESS" mycli'

[[ $OSTYPE != darwin* ]] && {
  alias p="paru"
  alias pn="paru --noconfirm"
} || {
  (( ${+commands[pacaptr]} )) && {
    alias pacman='pacaptr'
    alias p='pacaptr'
    alias co='p --using conda'
    alias tlm='p --using tlmgr'
    alias pipp='p --using pip'
  }
}

alias pat='bat --style=header'
alias duso='du -hsx * | sort -rh | bat --paging=always'

alias nnn='nnn -Caxe'
alias lsn='nnn -deH'
alias nnncdu='nnn -T d -dH'

alias dic='trans -d'
alias checkrootkits="sudo rkhunter --update; sudo rkhunter --propupd; sudo rkhunter --check"
alias checkvirus="clamscan --recursive=yes --infected $HOME/"
alias updateantivirus="sudo freshclam"

# === trash =====================================================================
(( ${+commands[rip]} )) && alias rr="rip"

(( ${+commands[trash-put]} )) && {
  alias rrr='trash-put'
  alias tre='trash-empty'
  alias trl='trash-list'
  alias trr='trash-restore'
  alias trm='trash-rm'
}

alias vi="$EDITOR"
alias svi="sudo $EDITOR"
alias sv="sudo $EDITOR"
alias vimdiff='nvim -d'
alias jrnlw='jrnl wiki'
alias nb='BROWSER=w3m nb'
# alias jrnl='jrnl'

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
