local M = {}

local D = require("dev")
local paint = D.npcall(require, "paint")
if not paint then
    return
end

function M.setup()
    paint.setup(
        {
            -- @type PaintHighlight[]
            highlights = {
                {
                    filter = {filetype = "lua"},
                    pattern = "%s(@%w+)",
                    -- pattern = "%s*%-%-%-%s*(@%w+)",
                    hl = "SpellCap"
                },
                {
                    filter = {filetype = "c"},
                    -- pattern = "%s*%/%/%/%s*(@%w+)",
                    pattern = "%s(@%w+)",
                    hl = "@parameter"
                },
                {
                    filter = {filetype = "python"},
                    -- pattern = "%s*%/%/%/%s*(@%w+)",
                    pattern = "%s(@%w+)",
                    hl = "@parameter"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%*.-%*", -- *foo*
                    hl = "Title"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%*%*.-%*%*", -- **foo**
                    hl = "Error"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%s_.-_", --_foo_
                    hl = "MoreMsg"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%s%`.-%`", -- `foo`
                    hl = "Keyword"
                },
                {
                    filter = {filetype = "markdown"},
                    pattern = "%`%`%`.*", -- ```foo<CR>...<CR>```
                    hl = "MoreMsg"
                }
            }
        }
    )
end

local function init()
    M.setup()
end

init()

return M
