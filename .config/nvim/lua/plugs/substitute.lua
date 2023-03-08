local M = {}

local D = require("dev")
local sub = D.npcall(require, "substitute")
if not sub then
    return
end

local utils = require("common.utils")
local map = utils.map
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
                register = nil
                -- motion1 = true,
                -- motion2 = true,
            }
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

    wk.register(
        {
            ["s"] = {"<Cmd>lua require('substitute').operator()<CR>", "Substitute: <motion>"},
            ["ss"] = {"<Cmd>lua require('substitute').line()<CR>", "Substitute: line"},
            ["se"] = {"<Cmd>lua require('substitute').eol()<CR>", "Substitute: EOL"},
            ["sx"] = {
                "<Cmd>lua require('substitute.exchange').operator()<CR>",
                "Substitute Exchange: <motion>"
            },
            ["sxx"] = {
                "<Cmd>lua require('substitute.exchange').line()<CR>",
                "Substitute Exchange: line"
            },
            ["sxc"] = {
                "<Cmd>lua require('substitute.exchange').cancel()<CR>",
                "Substitute Exchange: cancel"
            },
            ["<Leader>sr"] = {
                "<Cmd>lua require('substitute.range').operator()<CR>",
                "Substitute Range: <motion><motion>"
            },
            ["sr"] = {
                "<Cmd>lua require('substitute.range').word()<CR>",
                "Substitute Range: <word><motion>"
            },
            ["sS"] = {
                "<Cmd>lua require('substitute.range').operator({confirm = true})<CR>",
                "Substitute Range: <motion><motion> confirm"
            }
        }
    )

    -- TIP: ====================================================================
    -- `:h pattern-overview`
    -- {-}: matches 0 or more of the preceding atom, as few as possible
    --
    -- Replace Nth occurence:        s/\v(.{-}\zsPATT.){N}/REPL/
    -- Replace every Nth occurrence: s/\v(\zsPATT.{-}){N}/REPL/g
    -- Sort on a given column:       :sort f /\v^(.{-},){2}/

    -- ["<Leader>sr"] = {[[:%s/\<<C-r><C-w>\>/]], "Replace word under cursor"}

    map(
        "n",
        "s;",
        D.ithunk(range.word, {motion2 = "ie"}),
        {desc = "Substitute Range: <word><file>", silent = false}
    )

    -- map("x", "p", "<cmd>lua require('substitute').visual()<cr>")
    -- map("x", "P", "<cmd>lua require('substitute').visual()<cr>")

    wk.register(
        {
            ["ss"] = {"<Cmd>lua require('substitute').visual()<CR>", "Substitute: visual"},
            ["X"] = {"<Cmd>lua require('substitute.exchange').visual()<CR>", "Substitute Exchange: selection"},
            ["sr"] = {"<Cmd>lua require('substitute.range').visual()<CR>", "Substitute <motion>"}
        },
        {mode = "x"}
    )
end

init()

return M
