#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2023-05-29 19:11
#===========================================================================

# @desc buku bookmark manager (fzf)

emulate -L zsh
setopt extendedglob warncreateglobal typesetsilent \
        noshortloops rcquotes noautopushd

typeset -g BUKU_SHOW
typeset -ga match mbegin mend reply
typeset -g db query
db="$XDG_DATA_HOME/buku/bookmarks.db"

function .buku_print() {
  (( BUKU_SHOW )) && {
    builtin print -Pr -- "%F{52}buku%f %F{2}$1%f ${@:2}"
  }
}

function @buku_get() {
  local sql
  sql="SELECT id,URL,metadata,tags FROM bookmarks $query"
  reply=($(
    sqlite3 -separator $'\t' "$db" "$sql" \
      | perl -F'\t' -lne 'BEGIN{$,="\t"} $F[3] =~ s/(^,|,$)//g; print @F' \
      | fzf \
            ${${(z)${(j. .)BUKU_FZF_OPTS}}//\'} \
            --multi \
            --reverse \
            --tac \
            --query "${${*:2}:-}" \
            --delimiter '\t' \
            --bind='ctrl-e:execute(buku -w {1} < /dev/tty > /dev/tty)' \
            --preview "buku --nostdin -p {1}" \
            --preview-window=wrap \
      | ${commands[hck]:-cut} -f${1:-2}
  ))
}

# buku: get bookmark ids
function @buku_get_ids() {
  @buku_get 1
}

function @buku_get_urls() {
  @buku_get 2
}

function @buku_get_urls_by_tags() {
  local MATCH; integer MBEGIN MEND
  query=${(j: and tags LIKE :)${(qq)${@//(#m)*/%${MATCH}%}}}
  @buku_get_urls
}

# @desc use fzf to open bookmark with buku
# Can also do this; but it looks ugly
#   `function b1fo bo() {}`
function b1fo() {
  local url
  @buku_get_urls
  for url ($reply[@]) {
    background! "handlr open $url"
    # background! "$BROWSER $url"
  }
}
functions -c b1fo bo

function b1fo_tmux() {
  local url
  @buku_get_urls
  for url ($reply[@]) {
    $BROWSER $url
  }
}

# @desc use fzf to open bookmark with buku (search by tag first) in GUI
function b1fot() {
  local url
  @buku_get_urls_by_tags "$@"
  for url ($reply[@]) {
    background! "$BROWSER $url"
  }
}
functions -c b1fot bot

# @desc use fzf to open bookmark in w2m
function b1fow() {
  local url
  @buku_get_urls
  for url ($reply[@]) {
    w3m "$url"
  }
}
functions -c b1fow bow

# buku: fzf open builtin
function b1o() {
  local id
  @buku_get_ids
  for id ($reply[@]) {
    command buku --open "$id"
  }
}

# buku: fzf update
function b1fui() {
  local url
  @buku_get_urls
  for url ($reply[@]) {
    command buku --update "$url" "$@"
  }
}

# @desc use fzf to edit bookmark with buku
function b1e() {
  local id
  @buku_get_ids
  for id ($reply[@]) {
    command buku --write "$id"
  }
}
functions -c b1e be

# @desc buku - delete
function b1d() {
  local id
  @buku_get_ids
  for id ($reply[@]) {
    command buku --delete "$id"
  }
}

# @desc buku - 'u'pdate 'ti'tile
function b1uti() {
  command buku -u "$1" --title "${(z)@:2}"
}

# @desc buku - 'u'pdate 'ti'tile
function b1futi() {
  (( ! $#@ )) && { zerr "a title is needed"; return 1; }
  local id
  @buku_get_ids
  for id ($reply[@]) {
    command buku -u "$id" --title + ${(j.,.)@}
  }
}

# @desc buku - remove tags
function b1rt() {
  if (( $# == 2 )) {
    command buku -u "$1" --tag - ${(j.,.)@:2}
  } else {
    command buku --replace "$1"
  }
}

# @desc buku -- update tags
function b1ut() {
  command buku -u "$1" --tag + ${(j.,.)@:2}
}

# @desc buku -- fzf update tags
function b1fut() {
  (( ! $#@ )) && { zerr "a tag is needed"; return 1; }
  local id
  @buku_get_ids
  for id ($reply[@]) {
    command buku -u "$id" --tag + ${(j.,.)@}
  }
}

# @desc buku -- add tags
function b1at() {
  command buku --suggest --colors cJelo -a "$1" ${(z)@:2}
}
functions -c b1at ba

# @desc a copy of bow but as a zsh func
function :b1fow() {
  b1fow
  if (($+WIDGET)); then
    zle redisplay
    # zle .reset-prompt
    # zle -R
  fi
}

# @desc Copy the URL
function b1cp() {
  local url
  @buku_get_urls
  for url ($reply[@]) {
    xsel -ib --trim <<< "$url"
  }
}

# buku --np -t | awk 'gsub( /\(|\)$/, "" ) { $1 = $NF; $NF = ""; print }' | sort -nr

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
