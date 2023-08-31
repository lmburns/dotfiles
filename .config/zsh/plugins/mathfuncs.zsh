#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-23                                                   #
#    @module: mathfuncs                                                    #
#      @desc: Mathematical functions                                       #
#===========================================================================

# TODO: this may not work, but i thought i got it to
# @desc: check an identifiers type (math version)
function math::type() {
  local var=$1 tpe=$2 attr=$3
  integer ret
  # dunstify "ret:$ret reply:$REPLY var:$var P:${(P)var} tpe:$tpe attr:$attr"
  dunstify "var:$var P:${(P)var} tpe:$tpe attr:$attr"
  if (($#attr)); then
    ret=$(( $(@type -t $tpe -a $attr $var) ))
    (( ret ? 0 : 1 )); true
  else
    ret=$(( $(@type -t $tpe $var) ))
    (( ret ? 0 : 1 )); true
  fi
}
functions -M type 2 3 math::type


# @desc: check an identifiers type + attribute (math version)
function math::typea() {
  @type -t $1 -a $2 $3
  integer ret=$((! $?))
  (( ret ? 0 : 1 ))
  return
}
functions -M typea 3 3 math::typea

# @desc: return a capped column limit
function math::get_cols() {
  return 'COLUMNS > 88 ? 88 : COLUMNS'
}
functions -M cols 0 0 math::get_cols
