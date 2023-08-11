local lazy = require("usr.lazy")
local F = lazy.require("usr.shared.F") ---@module 'usr.shared.F'
local it = F.ithunk
local mpi = lazy.require("usr.api") ---@module 'usr.api'
local bmap0 = mpi.bmap0

local o = vim.opt_local
local fn = vim.fn
local cmd = vim.cmd

---
---@param word? string|boolean if true, use cWORD
local function kw_prog(word)
    local cword = word
    cword = F.is.str(word) and word or Rc.api.opt.tmp_call(
        {opt = "iskeyword", val = ("%s,."):format(vim.bo.iskeyword)},
        it(fn.expand, F.ife_true(word, "<cWORD>", "<cword>"))
    )
    cword = cword or word

    local ok, _msg = pcall(cmd.Man, word)
    if not ok then
        local split_word = vim.split(word, ".", {plain = true})
        ok, _msg = pcall(cmd.Man, split_word[#split_word])
    end
end

o.list = false
-- o.buflisted = false
o.bufhidden = "hide"
o.relativenumber = false
o.signcolumn = "no"
o.colorcolumn = ""
o.foldmethod = "syntax"

bmap0("n", "M", kw_prog, {desc = "Man of <cword>"})
bmap0("n", "go", "<Plug>(InfoUp)", {desc = "Info: up"})
bmap0("n", "gh", "<Plug>(InfoNext)", {desc = "Info: next"})
bmap0("n", "gl", "<Plug>(InfoPrev)", {desc = "Info: prev"})
bmap0("n", "gm", "<Plug>(InfoMenu)", {desc = "Info: menu"})
bmap0("n", "gd", "<Plug>(InfoFollow)", {desc = "Info: follow"})
bmap0("n", "gt", "<Plug>(InfoGoto)", {desc = "Info: goto"})

bmap0("n", "<Up>", "<Plug>(InfoUp)", {desc = "Info: up"})
bmap0("n", "<Right>", "<Plug>(InfoNext)", {desc = "Info: next"})
bmap0("n", "<Left>", "<Plug>(InfoPrev)", {desc = "Info: prev"})
bmap0("n", "<BS>", "<Plug>(InfoPrev)", {desc = "Info: prev"})
bmap0("n", "?", "<Plug>(InfoMenu)", {desc = "Info: menu"})
bmap0("n", "<CR>", "<Plug>(InfoFollow)", {desc = "Info: follow"})
bmap0("n", "<Down>", "<Plug>(InfoGoto)", {desc = "Info: goto"})
