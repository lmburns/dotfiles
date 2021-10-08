############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# alias xevk="xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'"

alias -g G='| rg '
alias -g H='| head'
alias -g T='| tail'

alias xp="xplr"
alias xx="xcompress"
alias ca='cargo'
alias cat="bat"

alias xmm="xmodmap"
alias jo="journalctl"
alias s="systemctl"

alias passver="veracrypt --text --keyfiles ~/.password.vera.key --pim=0 --protect-hidden=no --mount ~/.password.vera ~/.local/share/password-store"
alias passverr="veracrypt --text --dismount ~/.password.vera"

alias zstats='zstat -sF "%b %e %H:%M:%S"'

alias ctrim='par -vun "cd {} && cargo trim clear" ::: $(fd -td -d1)'

(( ${+commands[stylua]} )) && alias stylua="stylua -c $XDG_CONFIG_HOME/stylua/stylua.toml"
alias :q='exit'
alias ng="noglob"

alias ja="jaime"

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
  alias pe="pet exec"
  alias pee="pet edit"
}

(( ${+commands[hoard]} )) && {
  alias hd='hoard -c $XDG_CONFIG_HOME/hoard/hoard.toml -h $XDG_CONFIG_HOME/hoard/root'
  alias hde='hoard -c $XDG_CONFIG_HOME/hoard/hoard.toml -h /Volumes/SSD/manual-bkp/hoard'
  alias nhd='$EDITOR $XDG_CONFIG_HOME/hoard/hoard.toml'
  alias hdocs='hoard -c $XDG_CONFIG_HOME/hoard/docs-config -h $XDG_CONFIG_HOME/hoard/docs'
  alias hdocse='hoard -c $XDG_CONFIG_HOME/hoard/docs-config -h /Volumes/SSD/manual-bkp/hoard-docs'
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
alias yt='youtube-dl --add-metadata -i'
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

(( ${+commands[dua]} )) && alias ncdu='dua i'
(( ${+commands[coreutils]} )) && alias cu='coreutils'

# === configs ===================================================================
alias npoly='$EDITOR $XDG_CONFIG_HOME/polybar/config'
alias nx='$EDITOR $HOME/.xinitrc'

alias nrofi='$EDITOR $XDG_CONFIG_HOME/rofi/config.rasi'
alias nalac='$EDITOR $XDG_CONFIG_HOME/alacritty/alacritty.yml'
alias nprof='$EDITOR $HOME/.profile'
alias nzsh='$EDITOR $ZDOTDIR/.zshrc'
alias azsh='$EDITOR $ZDOTDIR/zsh.d/aliases.zsh'
alias bzsh='$EDITOR $ZDOTDIR/zsh.d/keybindings.zsh'
alias ndir='$EDITOR $ZDOTDIR/gruv.dircolors'
alias ezsh='$EDITOR $HOME/.zshenv'
alias ninit='$EDITOR $XDG_CONFIG_HOME/nvim/init.vim'
alias ncoc='$EDITOR $XDG_CONFIG_HOME/nvim/coc-settings.json'
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

[[ $OSTYPE = darwin* ]] && {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/yabai/yabairc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/skhd/skhdrc'
} || {
  alias nyab='$EDITOR $XDG_CONFIG_HOME/bspwm/bspwmrc'
  alias nskhd='$EDITOR $XDG_CONFIG_HOME/sxhkd/sxhkdrc'
}

alias srct='tmux source $XDG_CONFIG_HOME/tmux/tmux.conf'

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
alias toilet='toilet -d /usr/local/figlet/2.2.5/share/figlet/fonts'
alias downl='xh --download'
alias googler='googler --colors bjdxxy'

alias wget='wget --hsts-file $XDG_CONFIG_HOME/wget/.wget-hsts'
alias tsm='transmission-remote'
alias tsmd='transmission-daemon'
alias qbt='qbt torrent'

alias getip='ipconfig getifaddr en0 &&  curl ipecho.net/plain; echo'
alias dnsflush='sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache'
alias n1sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias n1httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias pyn='openpyn'
alias oconn='openpyn us -t 10'
alias spt='speedtest | rg "(Download:|Upload:)"'
alias essh='eval $(ssh-add)'
alias kc='keychain'
alias kck='keychain -k all'

# === fixes ===================================================================
alias xattr='/usr/bin/xattr'
alias id="/usr/bin/id"
alias idh="man /usr/share/man/man1/id.1"

# === mac specific =============================================================
(( ${${(M)OSTYPE:#*darwin*}:+1} )) && {
  alias lct='launchctl'
  alias pbc='pbcopy'
  alias pbp='pbpaste'
  alias keuze="keuze -fs 12 -fn Monaco"
  alias temp='osx-cpu-temp'
  alias wifi='osx-wifi-cli'
  alias nset='networksetup'
  alias snset='sudo networksetup'
  alias x1mute="osascript -e 'set volume output muted true'"
  alias x1emptytrash="osascript -e 'tell application \"Finder\" to empty trash'"
  alias x1lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
  alias loginscreen='sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText'
  # alias battemp="bc <<< \"scale=3; $(ioreg -r -n AppleSmartBattery | grep Temperature | cut -c23-)/100*1.8+32\""
  alias pbplain='pbpaste | textutil -convert txt -stdin -stdout -encoding 30 | pbcopy'
  alias spot='sudo mdutil -a -i'
  alias PlistBuddy='/usr/libexec/PlistBuddy'
  alias slocate='/usr/bin/locate'
  alias bundleident='mdls -name kMDItemCFBundleIdentifier -r'
  alias uti='mdls -name kMDItemContentType -name kMDItemContentTypeTree -name kMDItemKind'
  alias etch='sudo /Applications/balenaEtcher.app/Contents/MacOS/balenaEtcher'
  alias -s {log,out}='open -a Console'
  alias librewolf='/Applications/LibreWolf.app/Contents/MacOS/librewolf'
  alias firefox='/Applications/Firefox.app/Contents/MacOS/firefox-bin'
  alias x1email_screen="screencapture -C -M screen-`date +%d.%m.%Y-%H`.png"
  alias x1email_screen10s="screencapture -T 10 -C -M screen-`date +%d.%m.%Y-%H`.png"
  alias x1email_window="screencapture -W -M screen-`date +%d.%m.%Y-%H`.png"
  alias x1email_snippet="screencapture -s -M screen-`date +%d.%m.%Y-%H`.png"
}
# alias maclogout="osascript -e 'tell application \"System Events\" to log out'"
# bundlei() { osascript -e 'id of app "$1"' }

# === wiki ======================================================================
alias vw='$EDITOR $HOME/vimwiki/index.md'
alias vwd='$EDITOR $HOME/vimwiki/dotfiles/index.md'
alias vws='$EDITOR $HOME/vimwiki/scripting/index.md'
alias vwb='$EDITOR $HOME/vimwiki/blog/index.md'
alias vwl='$EDITOR $HOME/vimwiki/languages/index.md'

# === github ====================================================================
alias conf='/usr/bin/git --git-dir=$XDG_DATA_HOME/dotfiles-private --work-tree=$HOME'
alias xav='/usr/bin/git --git-dir=$XDG_DATA_HOME/dottest --work-tree=$HOME'

alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias gua='git remote | xargs -L1 git push --all'
alias grmssh='ssh git@burnsac.xyz -- grm'
alias h='git'
alias g='hub'
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
alias tno='terminal-notifier'

alias thumbs='thumbsup --input ./img --output ./gallery --title "images" --theme cards --theme-style style.css && rsync -av gallery root@burnsac.xyz:/var/www/lmburns'

alias nerdfont='source $XDG_DATA_HOME/fonts/i_all.sh'

alias mpd='mpd ~/.config/mpd/mpd.conf'
alias hangups='hangups -c $XDG_CONFIG_HOME/hangups/hangups.conf'
alias newsboat='newsboat -C $XDG_CONFIG_HOME/newsboat/config'
alias podboat='podboat -C $XDG_CONFIG_HOME/newsboat/config'
alias ticker='ticker --config $XDG_CONFIG_HOME/ticker/ticker.yaml'
alias abook='abook --config "$XDG_CONFIG_HOME"/abook/abookrc --datafile "$XDG_DATA_HOME"/abook/addressbook'
alias taske='task edit'
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'

(( ${+commands[tldr]} )) && alias tldru='tldr --update'
(( ${+commands[assh]} )) && alias hssh="assh wrapper ssh"

(( ${+commands[pueue]} )) && {
  alias pu='pueue'
  alias pud='pueued -dc "$XDG_CONFIG_HOME/pueue/pueue.yml"'
}
alias .ts='TS_SOCKET=/tmp/ts1 ts'
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
alias jrnl=' jrnl'
alias jrnlw=' jrnl wiki'
alias nb='BROWSER=w3m nb'

alias ume='um edit'

# === rsync =====================================================================
(( $+commands[rsync] )) && {
  alias rcp='rsync -av --ignore-existing --progress'
  alias rsyn='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS'

  alias rsynca='rsync -Pyuazv --info=progress2 --name=name0 --delete-after --exclude ".DS_Store" --exclude ".ipynb_checkpoints"'

  # Prugoptczl
  alias rsyncsrv='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after --exclude "/dev/*" --exclude "/proc/*" --exclude "/sys/*" --exclude "/tmp/*" \
    --exclude "/run/*" --exclude "/mnt/*" --exclude "/media/*" --exclude "swapfile" \
    --exclude "lost+found" root@lmburns.com:/ /Volumes/SSD/server-full'

  # rugoptczl --info=progress2 --info=name0
  alias wwwpull='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after root@lmburns.com:/var/www $HOME/server'
  alias wwwpush='rsync -rzau --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS \
    --delete-after --exclude ".DS_Store" $HOME/server /Volumes/SSD'
  alias sudorsync='sudo rsync -azurh --delete-after --include ".*" --exclude ".DS_Store" \
    --exclude ".ipynb_checkpoints" --exclude "/Volumes/*" --exclude "/cores/*" / /Volumes/SSD/void'
}

# === homebrew =====================================================================
(( ${${(M)OSTYPE:#*darwin*}:+1} )) && {
alias dmenu='open -a dmenu-mac'
alias br="brew"                     brana='brew analytics'      brcat='brew cat'
alias brcle='brew cleanup'          brcom='brew command'        brcoms='brew commands'
alias brcon='brew config'           brdep='brew deps'           brdes='brew desc'
alias brdiy='brew diy'              brdoc='brew doctor'         brfet='brew fetch'
alias brgis='brew gist-logs'        brhom='brew home'           brinf='brew info'
alias brins='brew install'          brlea='brew leaves'         brlis='brew list'
alias brln='brew ln'                brlog='brew log'            brmig='brew migrate'
alias brmig='brew missing'          broca='brew --cache'        brcas='brew install --cask'
alias broce='brew --cellar'         broen='brew --env'          bropr='brew --prefix'
alias bropt='brew options'          brore='brew --repository'   brout='brew outdated'
alias brove='brew --version'        brpin='brew pin'            brpos='brew postinstall'
alias brpru='brew prune'            brrea='brew readall'        brrei='brew reinstall'
alias brsea='brew search'           brsh='brew sh'              brsty='brew style'
alias brswi='brew switch'           brtap='brew tap'            brtapi='brew tap-info'
alias brtapp='brew tap-pin'         brtapu='brew tap-unpin'     bruin='brew uninstall'
alias bruli='brew unlink'           brupa='brew unpack'         brupd='brew update'
alias brupdr='brew update-reset'    brupg='brew upgrade'        brupi='brew unpin'
alias bruse='brew uses'             bruta='brew untap'          brse='brew services'
alias brseli='brew services list'   sbrse='sudo brew services'  brwh='brew which-formula'
alias brdescs='brew desc --search'  brusei='brew uses --installed' brlin='brew link'
alias brwhu='brew which-update'     brdept='brdep --tree --installed'

alias sppr='sbrse stop dnsmasq && sbrse stop stubby && sbrse stop privoxy'
alias stpr='sbrse start dnsmasq && sbrse start stubby && sbrse start privoxy'
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
