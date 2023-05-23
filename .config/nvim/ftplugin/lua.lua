local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local utils = shared.utils
local coc = require("plugs.coc")
local mpi = require("usr.api")
local log = require("usr.lib.log")

local fn = vim.fn
local cmd = vim.cmd

local function map(...)
    mpi.bmap(0, ...)
end

vim.bo.include = [[\v<((do|load)file|(x?p|lazy\.)?require|lazy\.(require_on\.(index|modcall|expcall|call_rec)|require_iff))[^''"]*[''"]\zs[^''"]+]]
-- o.matchpairs:append({"if:end", "function:end"})

---
---@param word? string|boolean if true, use cWORD
local function kw_prog(word)
    local iskeyword_og = vim.bo.iskeyword
    vim.bo.iskeyword = vim.bo.iskeyword .. ",."
    word = utils.is.str(word) and word or fn.expand(F.ife_true(word, "<cWORD>", "<cword>"))
    vim.bo.iskeyword = iskeyword_og

    if word:find("vim.api") then
        local _, finish = word:find("vim.api.")
        local api_fn = word:sub(finish + 1)
        cmd.help(api_fn)
    elseif word:find("api") then
        local _, finish = word:find("api.")
        local api_fn = word:sub(finish + 1)
        cmd.help(api_fn)
    elseif word:find("vim.fn") then
        local _, finish = word:find("vim.fn.")
        local api_fn = word:sub(finish + 1) .. "()"
        cmd.help(api_fn)
    else
        local ok, msg = pcall(cmd.help, word)
        if not ok then
            local split_word = vim.split(word, ".", {plain = true})
            ok, msg = pcall(cmd.help, split_word[#split_word])
            if not ok then
                log.warn(msg --[[@as string]], {title = "keyword helper"})
            end
        end
    end
end

map("n", "<Leader>tt", "<Plug>PlenaryTestFile", {desc = "Plenary test"})
map("n", "M", kw_prog, {desc = "Help of <cword>"})
map("n", "gM", it(kw_prog, true), {desc = "Help of <cWORD>"})
map("n", "<Leader>jR", it(coc.run_command, "sumneko-lua.restart", {}), {desc = "Reload LuaLS"})
