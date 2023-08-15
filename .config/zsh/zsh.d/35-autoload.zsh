#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: autoload                                                     #
#      @desc: Autoload and miscellaneous things                            #
#===========================================================================

stty intr '^C'
stty susp '^Z'
stty stop undef
stty discard undef <$TTY >$TTY

hash -d ghq=$HOME/ghq
hash -d pro=$HOME/projects
hash -d git=$HOME/projects/github
hash -d config=$XDG_CONFIG_HOME
hash -d nvim=$XDG_CACHE_HOME/nvim
hash -d vim=$HOME/.vim
hash -d zsh=$ZDOTDIR

# -i  = Load and ignore errors
# -a  = Equivalent to -ab
# -ab = Autoloads on a builtin call
# -ap = Autoloads on a parameter usage
# -aF = Autoloads on a given feature
# -mF = Loads on a given pattern match
# -ub = Unloads a builtin

# Autoload modules when the command is referenced
zmodload     zsh/zprof         # profiling
zmodload -i  zsh/sched         # scheduler; needed by zinit
zmodload -a  zsh/attr          zgetattr zsetattr zdelattr zlistattr # extended attr
zmodload -a  zsh/zpty          zpty
zmodload -a  zsh/param/private private
zmodload -a  zsh/stat          zstat
zmodload -ub compctl compcall  # unload
# Note that -m and -a can't be combined. I'd prefer the autoloaded solution
#    zmodload -mF zsh/files b:zf_\*
zmodload -aF zsh/files +b:zf_chgrp +b:zf_rmdir +b:zf_mv +b:zf_sync +b:zf_rm \
                       +b:zf_chmod +b:zf_chown +b:zf_ln +b:zf_mkdir

# zmodload -a  zsh/zutil         zformat zparseopts zregexparse zstyle
# zmodload -a  zsh/rlimit        limit ulimit unlimit
# zmodload -af zsh/mathfunc      abs ceil exp floor sqrt float int rint copysign fmod nextafter rand48
# zmodload -ap zsh/mapfile       mapfile
# zmodload -ac zsh/regex         regex-match
# zmodload -aF zsh/pcre          +b:pcre_compile +b:pcre_match +b:pcre_study +C:pcre-match
# zmodload -aF zsh/system        +b:syserror +b:sysread +b:syswrite +b:sysopen +b:sysseek \
#                                +b:zsystem  +f:systell +p:errnos   +p:sysparams
# zmodload -aF zsh/watch         -b:log +p:WATCH +p:watch
# zmodload -aF zsh/datetime      +b:strftime +p:epochtime

# autoload -Uz sticky-note regexp-replace
autoload -Uz zmv zargs zed zrecompile # sticky-note
autoload -Uz allopt # show all options
autoload -Uz relative
autoload -Uz zcalc zmathfunc
# autoload -Uz catch throw
zmathfunc

alias fned='zed -f' histed='zed -h'
alias zmv='noglob zmv -v'  zcp='noglob zmv -Cv' zmvn='noglob zmv -W'
alias zln='noglob zmv -Lv' zlns='noglob zmv -o "-s" -Lv'

# zmodload -F zsh/parameter p:functions_source
[[ -v aliases[run-help] ]] && unalias run-help
autoload -RUz run-help
autoload -Uz $^fpath/run-help-^*.zwc(N:t)
# autoload -Uz $functions_source[run-help]-*~*.zwc
