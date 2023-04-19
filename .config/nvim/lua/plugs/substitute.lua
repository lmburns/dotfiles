local M = {}

local D = require("dev")
local sub = D.npcall(require, "substitute")
if not sub then
    return
end

-- local utils = require("common.utils")
-- local map = utils.map
local wk = require("which-key")

function M.setup()
    sub.setup(
        {
            yank_substituted_text = false,
            range = {
                -- Substitution command that will be used (set it to `S` to use tpope/vim-abolish)
                prefix = "s",
                -- Suffix added at the end of the substitute command.
                -- E.g., can not save sub history calls by adding `| call histdel(':', -1)`
                suffix = "",
                -- Substitution command replace part will be set to the current text.
                -- E.g., instead of `s/pattern//g` you will have `s/pattern/pattern/g`.
                prompt_current_text = false,
                -- Capture substituted text as you can use `\1` to quickly reuse it
                group_substituted_text = true,
                -- Require there's word boundaries on each match (eg: `\<word\>` instead of word)
                complete_word = true,
                -- Will ask for confirmation for each substitutions
                confirm = false,
                -- Use the content of this register as replacement value
                register = nil,
                -- motion1 = true,
                -- motion2 = true,
            },
            -- exchange = {
            --     motion = false
            -- }
            -- on_substitute = function(event)
            --     require("yanky").init_ring("p", event.register, event.count, event.vmode:match("[vV]"))
            -- end
        }
    )
end

local function init()
    M.setup()

    local range = require("substitute.range")
    local exchange = require("substitute.exchange")

    wk.register(
        {
            ["s"] = {D.ithunk(sub.operator), "Substitute: <motion>"},
            ["ss"] = {D.ithunk(sub.line), "Substitute: line"},
            ["se"] = {D.ithunk(sub.eol), "Substitute: EOL"},
            ["sx"] = {D.ithunk(exchange.operator), "SubExchange: <motion>"},
            ["sxx"] = {D.ithunk(exchange.line), "SubExchange: line"},
            ["sxc"] = {D.ithunk(exchange.cancel), "SubExchange: cancel"},
            ["<Leader>sr"] = {D.ithunk(range.operator), "SubRange: <motion><motion>"},
            ["sr"] = {D.ithunk(range.word), "SubRange: <word><motion>"},
            ["sS"] = {D.ithunk(range.operator, {confirm = true}), "SubRange: <motion><motion> [y/N]"},
            ["s;"] = {D.ithunk(range.word, {motion2 = "ie"}), "SubRange: <word><file>"},
        }
    )

    -- ["<Leader>sr"] = {[[:%s/\<<C-r><C-w>\>/]], "Replace word under cursor"}
    -- map("x", "p", "<cmd>lua require('substitute').visual()<cr>")
    -- map("x", "P", "<cmd>lua require('substitute').visual()<cr>")

    wk.register(
        {
            ["ss"] = {D.ithunk(sub.visual), "Substitute: visual"},
            ["X"] = {D.ithunk(exchange.visual), "SubExchange: selection"},
            ["sr"] = {D.ithunk(range.visual), "SubRange: <motion>"},
            ["s;"] = {D.ithunk(range.visual, {motion2 = "ie"}), "SubRange: global"},
        },
        {mode = "x"}
    )
end

init()

return M
