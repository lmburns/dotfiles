############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# alias tlmgr="/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode"
# alias mail='/usr/bin/mail'
# alias strace="/usr/local/bin/strace"
# alias xevk="xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'"

# alias -g W="!"
alias -g G='| rg '      H='| head '      T='| tail '
alias -g B='| bat '     S='| sort '      U='| uniq '   M='| column -t'
alias -g CW='| cw'      RE='| tac '      F='| fzf'     C='| xsel -b --trim'
alias -g N='>/dev/null' NN='&>/dev/null' 2N='2>/dev/null '
alias -g CN="*(oc[1])" CNF="*(oc[1].)" CND="*(oc[1]/)" # inode change (new)
alias -g CO="*(Oc[1])" COF="*(Oc[1].)" COD="*(Oc[1]/)" # inode change (old)
alias -g AN="*(oa[1])" ANF="*(oa[1].)" AND="*(oa[1]/)" # access time (new)
alias -g AO="*(Oa[1])" AOF="*(Oa[1].)" AOD="*(Oa[1]/)" # access time (old)
alias -g MN='*(om[1])' MNF='*(om[1].)' MND='*(om[1]/)' # modification time (new)
alias -g MO='*(Om[1])' MOF='*(Om[1].)' MOD='*(Om[1]/)' # modification time (old)

alias {\$,%}=

(( ${+commands[surfraw]} )) && {
  alias srg='sr -g'
  alias srh='srg github'
  alias srl='BROWSER=$BROWSERCLI sr'
  alias srB='BROWSER=brave srg'
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
alias lynx="command lynx -vikeys -accept-all-cookies"
alias zman="BROWSER=$BROWSERCLI zman"
alias info='command info --vi-keys'

alias wh="whence -Sacx4"   # list all, csh style
alias wa="whence -Sav"     # where
alias wm="whence -Smv"     # pattern, verbose
alias wma="whence -Smav"   # pattern, list all, verbose
alias wM="whence -Smafvx4" # pattern, list all, verbose, function content

# === general ===================================================================
# alias _='sudo'
# alias __='doas'
alias usudo='sudo -E -s '
alias c='cdr'
alias f='pushd'
alias b='popd'
alias dirs='dirs -v'

alias :q='exit'
alias ng="noglob"
alias zstats='zstat -sF "%b %e %H:%M:%S"'
alias clear='clear -x' # don't clear scrollback buffer
alias sane='stty sane'
alias plast="last -20"

(( ! ABSD )) && {
  alias open="handlr open"
  alias jor="journalctl"
  alias jortoday="journalctl -xe --since=today"
  alias xmm="xmodmap"
  alias s="systemctl"
  alias se="systemctl --user"
  alias bctl="bluetoothctl"
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

alias chx='command chmod ug+x'
alias chmx='command chmod -x'
alias cp='command cp -ivp --reflink=auto'
alias cpl='command cp -ivpa'
alias cpa='command cp -ivp --preserve=links,mode,ownership,xattr'
alias cpx='command cp -ivp --preserve=xattr'
alias mv='command mv -iv'
alias lns='command ln -siv'

alias kall='killall'
alias kid='kill -KILL'

# [[ -n "$NVIM_LISTEN_ADDRESS" ]] && alias nvim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
alias pvim='nvim -u NONE'
alias vi="$EDITOR"
alias svi="sudo $EDITOR"
alias nd='neovide'
alias vimdiff='nvim -d'

alias grep="command grep --color=auto --binary-files=without-match --directories=skip"
alias diff='diff --color=auto'
alias sha='shasum -a 256'

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

alias lsf='lsof -w'
alias n1lsfp='lsof -w -p' # Open files of process
alias n1sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias n1httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias vmst='vmstat -SM 1'
alias iost='iostat -y -d -h -t 1'
alias s1vmst=vmst
alias s1iost=iost

# (( ${+commands[dua]} )) && alias ncdu='dua i'
(( ${+commands[coreutils]} )) && alias cu='coreutils'

(( ${+commands[exa]} )) && {
  alias ls='exa -Fhb --git --icons'
  alias lss='ls --group-directories-first' # short norm dir-first
  alias lssa='ls -a'                        # short all

  alias ll='exa -FlahHgb --git --icons --time-style long-iso --octal-permissions' # long all
  alias lla='ls -l'                                                               # long norm
  alias lls='ll --group-directories-first'                                        # long all dir-first
  alias lj='ll --group-directories-first'

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
  alias lsmo='lsm *(D.Om[1,10])'
  # 10 newest files (modified)
  alias lsmn='lsm *(D.om[1,10])'

  # Sort by accessed
  alias lsa='ll --sort=accessed --accessed'
  alias lsr='ll --sort=accessed --accessed --reverse'
  # 10 oldest files (accessed)
  alias lsao='lsa *(D.Oa[1,10])'
  # 10 newest files (accessed)
  alias lsan='lsa *(D.oa[1,10])'

  # Sort by changed
  alias lsc='ll --sort=changed --changed'
  alias lscr='ll --sort=changed --changed --reverse'
  # 10 oldest files (changed)
  alias lsco='lsc *(D.Oc[1,10])'
  # 10 newest files (changed)
  alias lscn='lsc *(D.oc[1,10])'

  # Sort by created (born)
  alias lsb='ll --sort=created --created'
  alias lsbr='ll --sort=created --created --reverse'
  # 10 oldest files (created)
  # alias lsbo='lsc *(D.Oc[1,10])'
  # 10 newest files (created)
  # alias lsbn='lsc *(D.oc[1,10])'

  # Altered today
  alias lsat='lsc -d *(e-after today-N)'
  # Altered before today
  alias lsbt='lsc -d *(e-before today-N)'
  # Changed at least 2hrs ago
  alias lsa2='lsc -d *(ch+2)'
  # Changed within last 2hrs
  alias lsb2='lsc -d *(ch-2)'

  # Sort by size
  # alias lsz='exa -Flhb --git --sort=size --icons'
  alias lsz='ll --sort=size'
  alias lszr='ll --sort=size --reverse'
  # 10 biggest files
  alias lszb='lsz *(.OL[1,10])'
  # 10 smallest files
  alias lszs='lsz *(.oL[1,10])'
  # List empty files
  alias lsz0='lsz *(.L0)'
  alias lsze='lsz0'

  # User: root
  alias lsur='ll *(Nu0)'
  alias lst='ll --sort=type'

  alias lsd='exa -D --icons --git'
  # All directories and symlinks that point to dirs
  alias lsdl='ll -d *(-/)'
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
  alias lstr='tree 1 -@'
  alias ls@='exa -FlaHBb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  # alias ls@='exa -FlaHb --git --icons --time-style long-iso --no-permissions --octal-permissions --no-user -@'
  # alias lm='exa -l  --no-user --no-permissions --no-time -@'

  # Dotfiles
  alias ls.='exa -FHb --git --icons -d .*(.N)'
  alias ll.='ll -d -- .*(.N)'
}

(( ${+commands[fd]} )) && {
  alias fd='fd -Hi'
  alias fdi='fd -Hi --no-ignore'
  alias ifd='fdi'
  alias fdg='fd --glob'
  alias fdc='fd --color=always'
  alias fdr='fd --changed-within=20m -d1' # 'recent'
  alias fdrd='fd --changed-within=30m'    # 'recent, depth'
  alias fdrr='fd --changed-within=1m'     # 'really recent'
}

(( ${+commands[rg]} )) && {
  alias prg="rg --pcre2"                # pcre rg
  alias frg="rg --files-with-matches"   # only return filenames
  alias lrg="rg -F"                     # string literal
  alias irg="rg --no-ignore"            # don't respect ignore files
  alias RGV='RG -g "*.vim"'             # grep vim files only (interactively)
  alias RGL='RG -g "*.lua"'             # grep lua files only (interactively)
  alias RGN='RG -g "*.{lua,vim}"'       # grep lua and vim files only (interactively)
  alias RGR='RG -g "*.rs"'              # grep rust files only (interactively)
  alias RGT='RG -g "*.{ts,tsx}"'        # grep typescript files only (interactively)
  alias RGJ='RG -g "*.{js,jsx}"'        # grep javascript files only (interactively)
  alias RGE='RG -g "*.{ts,tsx,js,jsx}"' # grep ecma files only (interactively)
  alias RGP='RG -g "*.py"'              # grep python files only (interactively)
  alias RGG='RG -g "*.go"'              # grep go files only (interactively)
  alias RGZ='RG -g "*.zsh"'              # grep go files only (interactively)
}

# === configs ===================================================================
alias nx='$EDITOR $HOME/.xinitrc'
alias ezsh='$EDITOR $HOME/.zshenv'
alias nzsh='$EDITOR $ZDOTDIR/.zshrc'
alias azsh='$EDITOR $ZDOTDIR/zsh.d/aliases.zsh'
alias fzsh='$EDITOR $ZDOTDIR/zsh.d/functions.zsh'
alias czsh='$EDITOR $ZDOTDIR/zsh.d/completions.zsh'
alias bzsh='$EDITOR $ZDOTDIR/zsh.d/keybindings.zsh'
alias lzsh='$EDITOR $ZDOTDIR/zsh.d/lficons.zsh'
alias nvivid='$EDITOR $ZDOTDIR/zsh.d/vivid/filetypes.yml'
alias nbsh='$EDITOR $HOME/.bashrc'
alias nalac='$EDITOR $XDG_CONFIG_HOME/alacritty/alacritty.yml'
alias nwez='$EDITOR $XDG_CONFIG_HOME/wezterm/wezterm.lua'
alias npoly='$EDITOR $XDG_CONFIG_HOME/polybar/config.ini'
alias npicom='$EDITOR $XDG_CONFIG_HOME/picom/picom.conf'
alias ndunst='$EDITOR $XDG_CONFIG_HOME/dunst/dunstrc'
alias nssh='$EDITOR $HOME/.ssh/config'
alias nnvi='$EDITOR $NVIMRC'
alias nvi='$EDITOR $MYVIMRC'
alias ntmux='$EDITOR $XDG_CONFIG_HOME/tmux/tmux.conf'
alias ntmuxi='$EDITOR $XDG_CONFIG_HOME/tmuxinator/lwm.yml'
alias ntask='$EDITOR $XDG_CONFIG_HOME/task/taskrc'
alias nlfr='$EDITOR $XDG_CONFIG_HOME/lf/lfrc'
alias nlfrs='$EDITOR $XDG_CONFIG_HOME/lf/scope'
alias nxplr='$EDITOR $XDG_CONFIG_HOME/xplr/init.lua'
alias nw3m='$EDITOR $HOME/.w3m/keymap'
alias ngit='$EDITOR $XDG_CONFIG_HOME/git/config'
alias ntig='$EDITOR $TIGRC_USER'
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
alias locld='cd $XDG_DATA_HOME'
alias docd='cd $HOME/Documents'
alias cvd='cd $HOME/Documents/cv'
alias downd='cd $HOME/Downloads'
alias mbd='cd $HOME/mybin'
alias vwdir='cd $HOME/vimwiki'
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
alias vw='$EDITOR $HOME/vimwiki/index.md'
alias vwd='$EDITOR $HOME/vimwiki/dotfiles/index.md'
alias vws='$EDITOR $HOME/vimwiki/scripting/index.md'
alias vwB='$EDITOR $HOME/vimwiki/blog/index.md'
alias vwl='$EDITOR $HOME/vimwiki/languages/index.md'
alias vwz='$EDITOR $HOME/vimwiki/languages/zsh/index.md'
alias vwL='$EDITOR $HOME/vimwiki/linux/index.md'
alias vwc='$EDITOR $HOME/vimwiki/linux/programs.md'
alias vwo='$EDITOR $HOME/vimwiki/other/index.md'
alias vwt='$EDITOR $HOME/vimwiki/todos.md'
alias vwb='$EDITOR $HOME/vimwiki/browser/index.md'

# === github ====================================================================
alias tigdb="GIT_DIR=$DOTBARE_DIR GIT_WORK_TREE=$DOTBARE_TREE tig"
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
# alias abook='abook --config "$XDG_CONFIG_HOME"/abook/abookrc --datafile "$XDG_DATA_HOME"/abook/addressbook'
# alias mbsync='mbsync -c $MBSYNCRC'

alias ume='um edit'

alias tt="taskwarrior-tui"
alias t="task"
alias te='t edit'
alias taske='t edit'
alias th='threadwatcher'
alias tha='th add'

alias jrnlw='jrnl wiki'
# alias nb='BROWSER=w3m nb'
# alias jrnl='jrnl'

alias tm='tmsu'
alias ja="jaime"
alias xx="xcompress"
alias ca='cargo'
alias cat="bat"
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
