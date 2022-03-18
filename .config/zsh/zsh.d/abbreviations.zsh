#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2022-03-15 19:39
#===========================================================================

(( $+functions[abbr] )) || return

local -a abbrs; abbrs=( ${(@f)"$(abbr list-abbreviations)"} )
# Seems ridiculous to have this below; couldn't find another way to do so
declare -Ag abbreviations; abbreviations=( ${(@f)${(@f):-"$(abbr list)"}/=/$'\n'} )

(( $abbrs[(I)localdocker] )) || abbr localdocker="DOCKER_HOST= DOCKER_TLS_PATH= DOCKER_TLS_VERIFY= docker"
(( $abbrs[(I)buildmusl] )) || abbr buildmusl='cargo build --target x86_64-unknown-linux-musl --release'
