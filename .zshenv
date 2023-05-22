############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

skip_global_compinit=1

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh" # Only one that is actually needed
export ZHOMEDIR="${XDG_CONFIG_HOME}/zsh"
export ZRCDIR="${ZHOMEDIR}/zsh.d"
export ZDATADIR="${XDG_DATA_HOME}/zsh"
export ZCACHEDIR="${XDG_CACHE_HOME}/zsh"

builtin source ${ZDOTDIR}/.zshenv

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]
