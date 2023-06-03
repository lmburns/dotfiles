#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2023-05-31 18:06
#    Module: zle-utils
#===========================================================================

function zredraw-prompt() {
  local precmd
  for precmd ($precmd_functions[@]) { $precmd }
  zle reset-prompt
}
