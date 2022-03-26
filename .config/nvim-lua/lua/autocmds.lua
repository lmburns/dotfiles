local utils = require("common.utils")
local autocmd = utils.autocmd
local augroup = utils.augroup

-- Spelling
autocmd(
    "spell", {
      [[FileType text,gitcommit,markdown,mail setlocal spell]],
      [[BufRead,BufNewFile neomutt-void* setlocal spell]],
    }, true
)

-- Return to last position in file
autocmd(
    "jump_last_position", {
      [[
        BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
      ]],
    }, true
)

-- Automatically reload buffer if changed outside current buffer
autocmd(
    "auto_read", {
      [[FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() == 'n' && getcmdwintype() == '' | checktime | endif]],
      [[FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded!" | echohl None]],
    }, true
)

-- === Custom file type settings === [[[
autocmd(
    "custom_ft", {
      [[BufRead,BufNewFile *.ztst            setl ft=ztst]],
      [[BufRead,BufNewFile *pre-commit       setl ft=sh]],
      [[BufNewFile,BufRead coc-settings.json setl ft=jsonc]],
      [[FileType json syntax match Comment +\/\/.\+$+]],
      [[BufRead,BufNewFile calcurse-note*,~/.local/share/calcurse/notes/* set filetype=markdown]],
      [[BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff]],
      [[BufRead,BufNewFile *.tex set filetype=tex]],
      [[FileType nroff setl wrap textwidth=85 colorcolumn=+1]],
      [[Filetype *json setl shiftwidth=2]],

      [[BufWritePre * %s/\s\+$//e            " End of lines]],
      [[BufWritePre * %s#\($\n\s*\)\+\%$##e  " End of file]],
      [[FileType * setl formatoptions-=cro   " Disable automatic comment]],

      [[BufReadPre   *.docx silent set ro]],
      [[BufEnter     *.docx silent set modifiable]],
      [[BufEnter     *.docx silent  %!pandoc --columns=78 -f docx -t markdown "%"]],
      [[BufWritePost *.docx :!pandoc -f markdown -t docx % > tmp.docx]],

      [[BufReadPre *.odt silent set ro]],
      [[BufEnter   *.odt silent  %!pandoc --columns=78 -f odt -t markdown "%"]],

      [[BufReadPre *.rtf silent set ro]],
      [[BufReadPost *.rtf silent %!unrtf --text]],
    }, true
)
-- ]]] === Custom file type ===

-- === Custom syntax groups === [[[
autocmd(
    "ccommtitle", {
      [[ Syntax * syn match ]] ..
          [[ cmTitle /\v(#|--|\/\/|\%)\s*(\u\w*|\=+)(\s+\u\w*)*(:|\s*\w*\s*\=+)/ ]] ..
          [[ contained containedin=.*Comment,vimCommentTitle,rustCommentLine ]],

      [[ Syntax * syn match myTodo ]] ..
          [[/\v(#|--|\/\/|")\s(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|CHECK|HACK|BUG|BUGS):/]] ..
          [[ contained containedin=.*Comment.*,vimCommentTitle ]],

      [[Syntax * syn keyword cmTitle contained=Comment]],
      [[Syntax * syn keyword myTodo contained=Comment]],
    }, true
)

cmd [[ hi def link cmTitle vimCommentTitle ]]
cmd [[ hi def link myTodo Todo ]]
-- cmd [[ hi def link cmLineComment Comment ]]

-- ]]] === Custom syntax groups ===

-- setup = {{'BufWritePost', 'plugins.lua', 'PackerCompile'},

-- ============================== Unused ============================== [[[

-- Toggle relative/non-relative nubmers on insert and normal mode
-- autocmd(
--     "number_toggle", {
--       [[BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif]],
--       [[BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif]],
--     }, true
-- )

-- ]]] === Unused ===

-- ========================== Tutorial ==========================

-- augroup(
--     "ClearCommandMessages", {
--       {
--         events = { "CmdlineLeave", "CmdlineChanged" },
--         targets = { ":" },
--         command = "lua require('as.autocommands').clear_messages()",
--       },
--     }
-- )

-- vim.api.nvim_create_autocmd(
--     { "BufEnter", "TermOpen", "TermEnter" }, {
--       group = groupname,
--       pattern = "term://*",
--       callback = function()
--         vim.keymap.set(
--             "n", "<CR>", function()
--               vim.cmd(
--                   [[call vimrc#open_file_with_line_col(expand('<cfile>'), expand('<cWORD>'))<CR>]]
--               )
--             end, { noremap = true, silent = true, buffer = true }
--         )
--       end,
--       once = false,
--     }
-- )
