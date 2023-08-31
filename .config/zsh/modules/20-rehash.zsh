autoload -U add-zsh-hook

# rehash on SIGUSR1
function TRAPUSR1() { rehash };

# anything newly intalled from last command?
function precmd_install() {
  [[ $history[$((HISTCMD-1))] == *(paru|pacman|pip)* ]] \
    && killall -u $USER -USR1 zsh
}

add-zsh-hook precmd precmd_install

# typeset -g PERIOD=3600                    # how often to execute $periodic
# function periodic() { builtin rehash; }   # this overrides the $periodic_functions hooks
