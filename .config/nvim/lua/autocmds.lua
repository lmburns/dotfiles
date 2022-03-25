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

-- setup = {{'BufWritePost', 'plugins.lua', 'PackerCompile'},

-- ============================== Unused ==============================
-- ====================================================================

-- Toggle relative/non-relative nubmers on insert and normal mode
-- autocmd(
--     "number_toggle", {
--       [[BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif]],
--       [[BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif]],
--     }, true
-- )

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
