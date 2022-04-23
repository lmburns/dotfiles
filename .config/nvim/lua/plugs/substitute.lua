local M = {}
local map = require("common.utils").map
local wk = require("which-key")

function M.setup()
    require("substitute").setup()
end

local function init()
    M.setup()

    wk.register({
        ["s"] = {"<Cmd>lua require('substitute').operator()<CR>", "Substitute operator"},
        ["ss"] = {"<Cmd>lua require('substitute').line()<CR>", "Substitute line"},
        ["se"] = {"<Cmd>lua require('substitute').eol()<CR>", "Substitute EOL"},
        ["sx"] = {"<Cmd>lua require('substitute.exchange').operator()<CR>", "Substitute exchange operator"},
        ["sxx"] = {"<Cmd>lua require('substitute.exchange').line()<CR>", "Substitute exchange line"},
        ["sxc"] = {"<Cmd>lua require('substitute.exchange').cancel()<CR>", "Substitute cancel"},
    })

    -- map("n", "s", ":lua require('substitute').operator()<CR>")
    -- map("n", "ss", ":lua require('substitute').line()<CR>")
    -- map("n", "se", ":lua require('substitute').eol()<CR>")
    map("x", "s", ":lua require('substitute').visual()<CR>")

    -- map("n", "sx", ":lua require('substitute.exchange').operator()<CR>")
    -- map("n", "sxx", ":lua require('substitute.exchange').line()<CR>")
    map("x", "X", ":lua require('substitute.exchange').visual()<CR>")
    -- map("n", "sxc", ":lua require('substitute.exchange').cancel()<CR>")
end

init()

return M
