#compdef rip

autoload -U is-at-least

_rip() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" \
        '-G+[Directory where deleted files go to rest]' \
        '--graveyard=[Directory where deleted files go to rest]' \
        '-u+[Undo the last removal, or specify some file(s) in the graveyard. Can be glob, or combined with -s (see --help)]' \
        '--unbury=[Undo the last removal, or specify some file(s) in the graveyard. Can be glob, or combined with -s (see --help)]' \
        '-m+[Set max depth for glob to search (default: 10)]' \
        '--max-depth=[Set max depth for glob to search (default: 10)]' \
        '-d[Permanently deletes (unlink) the entire graveyard]' \
        '--decompose[Permanently deletes (unlink) the entire graveyard]' \
        '-s[Prints files that were sent under the current directory]' \
        '--seance[Prints files that were sent under the current directory]' \
        '-f[Prints full path of files under current directory (with -s)]' \
        '--fullpath[Prints full path of files under current directory (with -s)]' \
        '-a[Prints all files in graveyard]' \
        '--all[Prints all files in graveyard]' \
        '-N[Do not use colored output (in progress)]' \
        '--no-color[Do not use colored output (in progress)]' \
        '-l[Undo files in current directory)]' \
        '--local[Undo files in current directory)]' \
        '-i[Prints some info about TARGET before prompting for action]' \
        '--inspect[Prints some info about TARGET before prompting for action]' \
        '-v[Print what is going on]' \
        '--verbose[Print what is going on]' \
        '-h[Prints help information]' \
        '--help[Prints help information]' \
        '-V[Prints version information]' \
        '--version[Prints version information]' \
        '*::TARGET -- File or directory to remove:_files' \
            && ret=0
}

_rip "$@"
