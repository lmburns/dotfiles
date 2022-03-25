local utils = require("common.utils")
local augroup = utils.augroup
local autocmd = utils.autocmd

autocmd(
    "spell", [[FileType text,gitcommit,markdown,mail setlocal spell]],
    [[BufRead,BufNewFile neomutt-void* setlocal spell]]
)

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
