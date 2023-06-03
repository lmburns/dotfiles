# autoload -Uz replace-string
# autoload -Uz replace-string-again
# zle -N replace-regex replace-string
# zle -N replace-pattern replace-string
# zle -N replace-string-again
# zstyle ':zle:replace-pattern' edit-previous false

# Modified the builtin becuase it doesn't act in one go

zstyle ':zle:@replace-pattern' edit-previous false

function @replace-string() {
  emulate -L zsh -o extendedglob
  autoload -Uz read-from-minibuffer @replace-string-again

  local p1  p2
  integer savelim=$UNDO_LIMIT_NO   changeno=$UNDO_CHANGE_NO
  local   start="$BUFFER"          cursor="$CURSOR"

  {

  if [[ -n $_replace_string_src ]]; then
    p1="[$_replace_string_src -> $_replace_string_rep]"$'\n'
  fi

  p1+="Replace: "; p2="   with: "

  # Saving curwidget is necessary to avoid the widget name being overwritten.
  local REPLY previous curwidget=$WIDGET

  if (( ${+NUMERIC} )); then
    (( $NUMERIC > 0 )) && previous=1
  else
    zstyle -t ":zle:$WIDGET" edit-previous && previous=1
  fi

  read-from-minibuffer $p1 ${previous:+$_replace_string_src} || return 1
  if [[ -n $REPLY ]]; then
    typeset -g _replace_string_src=$REPLY

    read-from-minibuffer "$p1$_replace_string_src$p2" \
      ${previous:+$_replace_string_rep} || return 1
    typeset -g _replace_string_rep=$REPLY
  fi

  } always {
    zle undo $changeno

    # Builtin does not do this
    UNDO_LIMIT_NO=savelim
    BUFFER="$start"
    CURSOR="$cursor"
  }

  @replace-string-again $curwidget
}

zle -N replace-pattern @replace-string
zle -N @replace-string


function @replace-string-again() {
  local MATCH MBEGIN MEND curwidget=${1:-$WIDGET}
  local -a match mbegin mend

  if [[ -z $_replace_string_src ]]; then
    zle -M "No string to replace."
    return 1
  fi

  if [[ $curwidget = *(pattern|regex)* ]]; then
      local rep2
      # The following horror is so that an & preceded by an even
      # number of backslashes is active, without stripping backslashes,
      # while preceded by an odd number of backslashes is inactive,
      # with one backslash being stripped.  A similar logic applies
      # to \digit.
      local rep=$_replace_string_rep
      while [[ $rep = (#b)([^\\]#)(\\\\)#(\\|)(\&|\\<->|\\\{<->\})(*) ]]; do
        if [[ -n $match[3] ]]; then
            # Expression is quoted, strip quotes
            rep2="${match[1]}${match[2]}${match[4]}"
        else
            rep2+="${match[1]}${match[2]}"
            if [[ $match[4] = \& ]]; then
          rep2+='${MATCH}'
            elif [[ $match[4] = \\\{* ]]; then
          rep2+='${match['${match[4][3,-2]}']}'
            else
          rep2+='${match['${match[4][2,-1]}']}'
            fi
        fi
        rep=${match[5]}
      done
      rep2+=$rep
      if [[ $curwidget = *regex* ]]; then
        autoload -Uz regexp-replace
        integer ret=1
        regexp-replace LBUFFER $_replace_string_src $rep2 && ret=0
        regexp-replace RBUFFER $_replace_string_src $rep2 && ret=0
        return ret
      else
        LBUFFER=${LBUFFER//(#bm)$~_replace_string_src/${(e)rep2}}
        RBUFFER=${RBUFFER//(#bm)$~_replace_string_src/${(e)rep2}}
      fi
  else
      LBUFFER=${LBUFFER//$_replace_string_src/$_replace_string_rep}
      RBUFFER=${RBUFFER//$_replace_string_src/$_replace_string_rep}
  fi
}

zle -N @replace-string-again

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
