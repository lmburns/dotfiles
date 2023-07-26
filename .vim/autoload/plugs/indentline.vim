" === IndentLine ========================================================= [[[
fun! plugs#indentline#setup() abort
    let g:indentLine_enabled = 1
    let g:indentLine_char = '|'
    let g:indentLine_char_list = ['|', '¦', '┇', '┋']
    let g:indentLine_first_char = '|'
    let g:indentLine_indentLevel = 20

    " let g:indentLine_fileTypeExclude = [
    "             \ "vimwiki",
    "             \ "coc-explorer",
    "             \ "help",
    "             \ "diff",
    "             \ "fzf",
    "             \ "floaterm",
    "             \ "markdown"
    "             \ ]
    let g:indentLine_bufNameExclude = [".*Wilder.*"]
    let g:indentLine_bufTypeExclude = ["help", "term:.*", "terminal"]

    let g:indentLine_showFirstIndentLevel = 0
    let g:indentLine_maxLines = 3000

    let g:indentLine_setColors = 1
    let g:indentLine_setConceal = 1
    let g:indentLine_defaultGroup = "ErrorMsg"
    let g:indentLine_color_tty_light = 7
    let g:indentLine_color_dark = 1
    let g:indentLine_color_term = 239
    let g:indentLine_color_gui = '#616161'

    let g:indentLine_faster = 0
    let g:indentLine_leadingSpaceEnabled = 0
    let g:indentLine_leadingSpaceChar = "•"
    let g:indentLine_concealcursor = "incv"
    let g:indentLine_conceallevel = 2

    augroup lmb__IndentLine
        autocmd!
        autocmd Filetype json,markdown let g:indentLine_setConceal = 0
    augroup END

    map <Leader>il <Cmd>IndentLinesToggle<CR>
endfun
" ]]]
