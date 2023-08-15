#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-14                                                   #
#    @module: lib                                                          #
#      @desc: Library functions for zsh, used by other scripts             #
#===========================================================================

# @desc: dump zsh hash
function dump_map() {
  eval "[[ \${(t)$1} = association ]]" || {
    (( ! $+1 )) && {
      xzmsg -h $funcstack[-1]:$LINENO "{func}$1{%} is not a hash"
    }
    # print::error "$1 is not a hash"
    return 1
  }

  eval "\
    for k ( \"\${(@k)$1}\" ) {
      print -Pr \"%F{2}\$k%f %F{1}%B=>%f%b %F{3}\$$1[\$k]%f\"
    }
  "
}

# http://wiki.fdiary.net/zsh/?cmd=view&p=PopFromArray&key=array
function pop() {
    local count=1
    [[ $1 == <-> ]] && {
        count=$1
        shift
    }
    for name in $*; do
        repeat $count do
            eval $name'[$#'$name']=()'
        done
    done
}

# 配列の末尾に引数を追加
# http://wiki.fdiary.net/zsh/?cmd=view&p=PushIntoArray&key=array
function push() {
    local name=$1
    shift
    eval $name'=($'$name' $*)'
}
