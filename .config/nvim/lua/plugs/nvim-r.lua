local utils = require("common.utils")

g.R_auto_start = 1 -- Autostart R when opening .R
g.R_assign_map = ";" -- Convert ';' into ' <-
g.r_syntax_folding = 1
g.r_indent_op_pattern = [[\(+\|-\|\*\|/\|=\|\~\|%\)$]] -- Indent automatically
g.R_rconsole_height = 10 -- Console height
g.R_csv_app = "terminal:vd" -- Use visidata to view dataframes
g.R_nvimpager = "tab" -- Use Vim to see R documentation
g.R_open_example = 1 -- Use Vim to display R examples
g.Rout_prompt_str = "$ " -- Start of R command prompt
g.Rout_continue_str = "... " -- Symbol for R string continuation
-- let R_specialplot = 1                                -- nvim.plot() instead of plot()
g.R_commented_lines = 0 -- Don't send commented lines to term
g.R_openpdf = 1 -- Automatically open PDFs
g.R_pdfviewer = "zathura" -- PDF viewer
g.R_close_term = 1 -- Close terminal when closing vim
g.R_objbr_place = "RIGHT" -- Location of object browser
g.Rout_more_colors = 1 -- Make terminal output more colorful
g.r_indent_align_args = 0 -- ?? where this come from
g.rout_follow_colorscheme = 0

cmd [[
  augroup r_env
    autocmd!
    autocmd FileType r,rmd,rnoweb
      \ if string(g:SendCmdToR) == "function('SendCmdToR_fake')"
        \ | call StartR("R") | endif|
      \ nnoremap <silent> ✠ :call SendLineToR("stay")<CR><Esc><Home><Down>|
      \ inoremap <silent> ✠ <Esc>:call SendLineToR("stay")<CR><Esc>A|
      \ vnoremap <silent> ✠ :call SendSelectionToR("silent", "stay")<CR><Esc><Esc>|
      \ inoremap <buffer> > <Esc>:normal! a %>%<CR>a|
      \ nnoremap <Leader>rs :vs ~/projects/rstudio/nvim-r.md<CR>|
      \ nnoremap <silent> <LocalLeader>t: call RAction("tail")<CR>|
      \ nnoremap <silent> <LocalLeader>H: call RAction("head")<CR>|
      \ vnoremap <silent> ;ff           :Rformat<cr>|
      \ nnoremap <buffer> ;fF           :Rformat<cr>|
      \ call     <SID>IndentSize(2)|
      if has('gui_running') || &termguicolors
        let rout_color_input    = 'guifg=#9e9e9e'
        let rout_color_normal   = 'guifg=#f79a32'
        let rout_color_number   = 'guifg=#889b4a'
        let rout_color_integer  = 'guifg=#a3b95a'
        let rout_color_float    = 'guifg=#98676a'
        let rout_color_complex  = 'guifg=#fcaf00'
        let rout_color_negnum   = 'guifg=#d7afff'
        let rout_color_negfloat = 'guifg=#d6afff'
        let rout_color_date     = 'guifg=#4c96a8'
        let rout_color_true     = 'guifg=#088649'
        let rout_color_false    = 'guifg=#ff5d5e'
        let rout_color_inf      = 'guifg=#f06431'
        let rout_color_constant = 'guifg=#5fafcf'
        let rout_color_string   = 'guifg=#502166'
        let rout_color_error    = 'guifg=#ffffff guibg=#dc3958'
        let rout_color_warn     = 'guifg=#f14a68'
        let rout_color_index    = 'guifg=#d3af86'
      endif
  augroup END
]]
