#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: dirstack                                                     #
#      @desc: Zsh dirstack setting                                         #
#===========================================================================

zmodload -i zsh/complist
zmodload -F zsh/parameter +p:dirstack
autoload -Uz chpwd_recent_dirs add-zsh-hook cdr zstyle+
add-zsh-hook chpwd chpwd_recent_dirs
# add-zsh-hook -Uz zsh_directory_name zsh_directory_name_cdr # cd ~[1]

zstyle+ ':chpwd:*' recent-dirs-default true \
      + ''         recent-dirs-max     20 \
      + ''         recent-dirs-file    "${Zfiles[CHPWD]}" \
      + ''         recent-dirs-prune   'pattern:/tmp(|/*)'
# + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs-${TTY##*/}" "${ZDOTDIR}/chpwd-recent-dirs" + \
# + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs-${TTY##*/}" \

zstyle ':completion:*' recent-dirs-insert  both

# Can be called across sessions to update the dirstack without sourcing
# This should be fixed to update across sessions without ever needing to be called
function set-dirstack() {
  [[ -v dirstack ]] || typeset -gaU dirstack
  dirstack=(
    ${(u)^${(@fQ)$(<${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null)}[@]:#(\.|$PWD|/tmp/*)}(N-/)
  )
}
set-dirstack

# Taken from romkatv/zsh4humans
# ${(D)PWD}
local dir=${(%):-%~}
[[ $dir = ('~'|/)* ]] && () {
  # if (( ! $#dirstack && (DIRSTACKSIZE || ! $+DIRSTACKSIZE) )); then
    local d stack=()
    foreach d ($dirstack) {
      {
        if [[ ($#stack -ne 0 || $d != $dir) ]]; then
          d=${~d}
          if [[ -d ${d::=${(g:ceo:)d}} ]]; then
            stack+=($d)
            (( $+DIRSTACKSIZE && $#stack >= DIRSTACKSIZE - 1 )) && break
          fi
        fi
      } always {
        let TRY_BLOCK_ERROR=0
      }
    } 2>/dev/null
    dirstack=($stack)
  # fi
}
