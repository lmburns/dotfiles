# Desc: BUKU bookmark manager

# Get bookmark ids
get_buku_ids() {
  buku -p -f 5 \
    | fzf --tac --layout=reverse-list -m \
    | hck -d $'\t' -f 1
}

# buku open
fb() {
  local -a ids; ids=( $(get_buku_ids) )
  print -Pr -- "%F{1}buku%f %F{2}--open%f ${ids[@]}"

  [[ -z $ids ]] && return 1

  command buku --open ${ids[@]}
}

# buku update
fbu() {
  local -a ids; ids=( $(get_buku_ids) )
  print -Pr -- "%F{1}buku%f %F{2}--update%f ${ids[@]} $@"

  [[ -z $ids ]] && return 0

  command buku --update ${ids[@]} $@
}

# buku write
fbw() {
  local -a ids; ids=( $(get_buku_ids) )

  foreach i (${ids[@]}) {
    command buku --write $i
    print -Pr -- "%F{1}buku%f %F{2}--write%f $i"
  }
}
