# Desc: BUKU bookmark manager

# get bookmark ids
get_buku_ids() {
    buku -p -f 5 | fzf --tac --layout=reverse-list -m | \
      cut -d $'\t' -f 1
    # awk -F= '{print $1}'
    # cut -d $'\t' -f 1
}

# buku open
fb() {
    # save newline separated string into an array
    ids=( $(get_buku_ids) )

    echo buku --open ${ids[@]}

    [[ -z $ids ]] && return 1 # return error if has no bookmark selected

    buku --open ${ids[@]}
}

# buku update
fbu() {
    # save newline separated string into an array
    ids=( $(get_buku_ids) )

    echo buku --update ${ids[@]} $@

    [[ -z $ids ]] && return 0 # return if has no bookmark selected

    buku --update ${ids[@]} $@
}

# buku write
fbw() {
    # save newline separated string into an array
    ids=( $(get_buku_ids) )
    # print -l $ids

    # update websites
    for i in ${ids[@]}; do
        echo buku --write $i
        buku --write $i
    done
}
