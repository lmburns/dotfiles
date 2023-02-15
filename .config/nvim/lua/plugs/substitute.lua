local M = {}

local D = require("dev")
local substitute = D.npcall(require, "substitute")
if not substitute then
    return
end

local wk = require("which-key")

function M.setup()
    substitute.setup(
        {
            yank_substitued_text = false,
            range = {
                prefix = "s",
                prompt_current_text = false,
                group_substituted_text = true,
                confirm = false,
                complete_word = false,
                motion1 = false,
                motion2 = false
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
    -- siw
    -- sxiw

    wk.register(
        {
            ["s"] = {"<Cmd>lua require('substitute').operator()<CR>", "Substitute operator"},
            ["ss"] = {"<Cmd>lua require('substitute').line()<CR>", "Substitute line"},
            ["se"] = {"<Cmd>lua require('substitute').eol()<CR>", "Substitute EOL"},
            ["sx"] = {"<Cmd>lua require('substitute.exchange').operator()<CR>", "Substitute exchange operator"},
            ["sxx"] = {"<Cmd>lua require('substitute.exchange').line()<CR>", "Substitute exchange line"},
            ["sxc"] = {"<Cmd>lua require('substitute.exchange').cancel()<CR>", "Substitute cancel"},
            ["<Leader>sr"] = {
                "<Cmd>lua require('substitute.range').operator()<CR>",
                "Substitute <motion><motion> operator"
            },
            ["sr"] = {
                "<Cmd>lua require('substitute.range').word()<CR>",
                "Substitute <motion> range word"
            },
            -- line word line line
            ["sS"] = {
                "<Cmd>lua require('substitute.range').operator({confirm = true})<CR>",
                "Substitute <motion><motion> confirm"
            }
        }
    )

    -- map("n", "s", ":lua require('substitute').operator()<CR>")
    -- map("n", "ss", ":lua require('substitute').line()<CR>")
    -- map("n", "se", ":lua require('substitute').eol()<CR>")
    -- map("x", "s", ":lua require('substitute').visual()<CR>")

    -- map("n", "sx", ":lua require('substitute.exchange').operator()<CR>")
    -- map("n", "sxx", ":lua require('substitute.exchange').line()<CR>")
    -- map("x", "X", ":lua require('substitute.exchange').visual()<CR>")
    -- map("n", "sxc", ":lua require('substitute.exchange').cancel()<CR>")

    wk.register(
        {
            ["ss"] = {"<Cmd>lua require('substitute').visual()<CR>", "Substitute visual"},
            ["X"] = {"<Cmd>lua require('substitute.exchange').visual()<CR>", "Substitute exchange line"},
            ["sr"] = {"<Cmd>lua require('substitute.range').visual()<cr>", "Substitute <motion>"}
        },
        {mode = "x"}
    )
end

init()

return M
