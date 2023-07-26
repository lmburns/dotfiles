local lazy = require("usr.lazy")
local F = lazy.require("usr.shared.F") ---@module 'usr.shared.F'
local it = F.ithunk
local coc = lazy.require("plugs.coc") ---@module 'plugs.coc'
local mpi = lazy.require("usr.api") ---@module 'usr.api'
local bmap0 = mpi.bmap0

local fn = vim.fn
local cmd = vim.cmd
local o = vim.opt_local

o.suffixesadd:prepend({".rs", "main.rs"})

-- sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,:///,://
-- s0:/*!,ex:*/,s1:/*,mb:*,:///,://!,://

-- bmap("n", "<Leader>h<CR>", ":T cargo clippy<CR>")
-- bmap("n", "<Leader>n<CR>", ":T cargo run -q<CR>")
-- bmap("n", "<Leader><Leader>n", ":T cargo run -q<space>")
-- bmap("n", "<Leader>b<CR>", ":T cargo build -q<CR>")
-- bmap("n", "<Leader>r<CR>", ":VT cargo play %<CR>")
-- bmap("n", "<Leader>v<CR>", ":T rust-script %<CR>")
-- bmap("n", "<Leader>e<CR>", ":T cargo eval %<CR>")

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

-- bmap0("n", ";ff", "keepj keepp RustFmt", {cmd = true, desc = "Rustfmt: file"})
-- bmap0("x", ";ff", "RustFmtRange", {cmd = true, desc = "Rustfmt: selected"})

bmap0("n", "M", kw_prog, {desc = "Man of <cword>"})
bmap0("n", "<Leader>K", it(kw_prog, true), {desc = "Man of <cWORD>"})
bmap0("n", "<Leader>tt<CR>", "<Cmd>RustTest<CR>", {desc = "Rust: run test"})

bmap0(
    "n",
    "vd",
    -- it(coc.run_command, "rust-analyzer.moveItemDown", {})
    "<Cmd>CocCommand rust-analyzer.moveItemDown<CR>",
    {desc = "Rust: move item down"}
)
bmap0(
    "n",
    "vu",
    -- it(coc.run_command, "rust-analyzer.moveItemUp", {})
    "<Cmd>CocCommand rust-analyzer.moveItemUp<CR>",
    {desc = "Rust: move item up"}
)
bmap0(
    "n",
    "<Leader>ex",
    -- it(coc.run_command, "rust-analyzer.expandMacro", {})
    "<Cmd>CocCommand rust-analyzer.expandMacro<CR>",
    {desc = "Rust: expand macro"}
)
bmap0(
    "n",
    "<Leader>jR",
    it(coc.run_command, "rust-analyzer.reloadWorkspace", {}),
    {desc = "Rust: reload workspace"}
)
