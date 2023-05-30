fun! plugs#asterisk#setup()
    let g:asterisk#keeppos = 1

    " Search forward <word>
    nmap * <Plug>(asterisk-z*)
    " Search backward <word>
    nmap # <Plug>(asterisk-z#)
    " Search forward word
    nmap g* <Plug>(asterisk-gz*)
    " Search backward word
    nmap g# <Plug>(asterisk-gz#)

    xmap * <Plug>(asterisk-z*)
    xmap # <Plug>(asterisk-z#)
    xmap g* <Plug>(asterisk-gz*)
    xmap g# <Plug>(asterisk-gz*)
endfun
