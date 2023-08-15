#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2023-05-31 18:06
#    Module: zle-utils
#===========================================================================

function :@zredraw-prompt() {
  local precmd
  for precmd ($precmd_functions[@]) { $precmd }
  zle reset-prompt
}; zle -N :@zredraw-prompt

# @desc: Add command to history without executing it
function :commit-to-history() {
  print -rs ${(z)BUFFER}
  # zle send-break
  zle end-of-history
}; zle -N :commit-to-history

function :@execute() {
  BUFFER="${(j:; :)@}"
  zle accept-line
}; zle -N :@execute

function :@replace-buffer() {
  LBUFFER="${(j:; :)@}"
  RBUFFER=""
}; zle -N :@replace-buffer

function :@append-to-buffer() {
  LBUFFER="${BUFFER}${(j:; :)@}"
}; zle -N :@append-to-buffer

function :@edit-file() {
  local -a args
  args=("${(@q)@}")
  BUFFER="${EDITOR} ${args}"
  zle accept-line
}; zle -N :@edit-file
