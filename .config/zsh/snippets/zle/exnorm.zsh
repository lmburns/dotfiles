# TODO: create a substitute command

# this script provides the ex-norm command, which allows executing !normal
# commands from vim/ex on the current BUFFER. for of reasonable vim-fu, this
# allows defining and repeating complex macros on the fly with little hassle.
# a history of commands is also kept, along with a widget to repeat the (n'th)
# last exnorm command.

# ex-norm-run may also non-interactively be called in widgets, which might be
# useful for defining widgets based on exnorm strings.

# using anonymous functions, which were introduced in 4.3.15
autoload -U is-at-least
is-at-least 4.3.15 || return

# applies $1 exnorm string to BUFFER
ex-norm-run () {

    # this is a widget!
    zle || return

    # this might be possible using only stdin/stdout like this
    # $(ex +ponyswag +%p - <<< $BUFFER)
    # but we play it safe using a temp file here.

    # use anonymous scope for a tempfile
    () {

        local -a posparams
        (( CURSOR > 0 )) && posparams=( +'set ww+=l ve=onemore' +"normal! gg${CURSOR}l" +'set ww-=l ve=' )

        # call ex in silent mode, move $CURSOR chars to the right with proper
        # wrapping, run the specified command in normal mode, prepend position
        # of the new cursor, write and exit.

        command vim -es $posparams \
            +"normal! $1" \
            +"let @a=col('.')" \
            +'normal! ggi ' \
            +'normal! "aP' \
            +wq "$2"

        result="$(<$2)"
        # new buffer
        BUFFER=${result#* }
        # and new cursor position
        CURSOR=$(( ${#${(M)result#* }} -1 ))

    } "$1" =(<<<"$BUFFER")

}

# ZSH_HIST_DIR from localhist, or just use $ZSH or just use $HOME
typeset -H ZSH_EXN_HIST=${ZSH_CACHE_DIR}/.zsh_exnhist
ex-norm () {

    # push exnorm history on stack, but only for the scope of this function
    fc -p -a $ZSH_EXN_HIST
    HISTNO=$HISTCMD

    # anonymous scope for recursive-edit foo
    () {

        local pos=$[ $#PREDISPLAY + $#LBUFFER ]
        # regular buffer is uninteresting for now.
        # show a space if RBUFFER is empty, otherwise there will be nothing to underline
        local pretext="$PREDISPLAY$LBUFFER${RBUFFER:- }$POSTDISPLAY
"
        local +h LBUFFER=""
        local +h RBUFFER=""
        local +h PREDISPLAY="${pretext}:normal! "
        local +h POSTDISPLAY=

        # underline the cursor position position, and highlight some stuff
        local +h -a region_highlight
        region_highlight=( "P$pos $[pos+1] underline" "P${#pretext} ${#PREDISPLAY} bold")

        # prevent zsh_syntax_highlighting from screwing up our region_highlight
        # not sure if this works with vanilla zsh_syntax_highlight...
        local ZSH_HIGHLIGHT_MAXLENGTH=0

        # let the user edit
        zle recursive-edit -K exnorm

        # everything ok? put BUFFER in REPLY then (and return accordingly)
        (( $? )) || REPLY=$BUFFER

    }

    # positive status and REPLY set?
    if (( $? == 0 )) && [[ -n $REPLY ]]; then
        # append to exnorm history
        print -sr -- ${REPLY%%$'\n'}
        # if we have a non-empty $REPLY, process with ex
        ex-norm-run $REPLY
    fi

}
zle -N ex-norm

# runs last exnorm command, or n'th last if there is a NUMERIC argument
ex-norm-repeat () {
    fc -p -a $ZSH_EXN_HIST

    # bail out if there is no such command in history
    [[ -n $history[$[HISTCMD-${NUMERIC:-1}]] ]] || return 1

    # run the ex command
    ex-norm-run $history[$[HISTCMD-${NUMERIC:-1}]]
}
zle -N ex-norm-repeat

# set up exnorm keymap
bindkey -N exnorm main

# might be nice to have some of the ^X as literals so they are passed to ex.
# not sure about this though, and there is always ^V...
# () {
#     setopt localoptions braceccl
#     # delete all prefix bindings
#     for x in {A-Z}; bindkey -M exnorm -r -p "^$x"
#     # delete all regular bindings
#     bindkey -M exnorm -R '^A-^L' self-insert
#     bindkey -M exnorm -R '^N-^Z' self-insert
# }

# these bindings may not be for everyone. I like them like this. jk is similar
# to jj for normal mode, q and @ are similar to the macro commands in vim.

# bindkey -M main qq ex-norm
# bindkey -M main @@ ex-norm-repeat
bindkey -M vicmd q ex-norm
bindkey -M vicmd @ ex-norm-repeat
