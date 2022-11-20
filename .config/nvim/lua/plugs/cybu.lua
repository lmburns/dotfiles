local M = {}

local D = require("dev")
local cybu = D.npcall(require, "cybu")
if not cybu then
    return
end

-- local hl = require("common.color")
-- local c = require("kimbox.palette").colors
local utils = require("common.utils")
-- local augroup = utils.augroup
local map = utils.map

function M.setup()
    cybu.setup(
        {
            position = {
                relative_to = "win", -- win, editor, cursor
                anchor = "topcenter", -- topleft, topcenter, topright,
                -- centerleft, center, centerright,
                -- bottomleft, bottomcenter, bottomright
                vertical_offset = -1, -- vertical offset from anchor in lines
                horizontal_offset = -1, -- vertical offset from anchor in columns
                max_win_height = 50, -- height of cybu window in lines
                max_win_width = 50 -- integer for absolute in columns
                -- float for relative to win/editor width
            },
            style = {
                path = "relative", -- absolute, relative, tail (filename only)
                path_abbreviation = "none", -- none, shortened
                border = "rounded", -- single, double, rounded, none
                separator = " ", -- string used as separator
                prefix = "…", -- string used as prefix for truncated paths
                padding = 1, -- left & right padding in number of spaces
                hide_buffer_id = false, -- hide buffer IDs in window
                devicons = {
                    enabled = true, -- enable or disable web dev icons
                    colored = true, -- enable color for web dev icons
                    truncate = true -- truncate wide icons to one char width
                },
                highlights = {
                    -- see highlights via :highlight
                    current_buffer = "WarningMsg", -- current / selected buffer
                    adjacent_buffers = "ErrorMsg", -- buffers not in focus
                    background = "Normal", -- window background
                    border = "FloatermBorder", -- border of the window
                    infobar = "StatusLine"
                }
                -- highlights = {
                --     current_buffer = "CybuFocus",
                --     adjacent_buffers = "CybuAdjacent",
                --     background = "CubuBackground",
                --     border = "CybuBorder",
                --     infobar = "CybuInfobar"
                -- }
            },
            behavior = {
                -- set behavior for different modes
                mode = {
                    default = {
                        switch = "immediate", -- immediate, on_close
                        view = "rolling" -- paging, rolling
                    },
                    last_used = {
                        switch = "on_close", -- immediate, on_close
                        view = "paging" -- paging, rolling
                    }
                }
            },
            display_time = 750, -- time the cybu window is displayed
            exclude = BLACKLIST_FT,
            fallback = function()
            end -- arbitrary fallback function
            -- used in excluded filetypes
        }
    )
end

local function init()
    M.setup()

    map("n", "[y", "<Plug>(CybuPrev)", {desc = "Cybu previous"})
    map("n", "]y", "<Plug>(CybuNext)", {desc = "Cybu next"})
    map({"n", "v"}, "<A-}>", "<Plug>(CybuLastusedNext)", {desc = "Cybu next last used"})
    map({"n", "v"}, "<A-{>", "<Plug>(CybuLastusedPrev)", {desc = "Cybu previously last used"})

    -- augroup(
    --     "lmb__Cybu",
    --     {
    --         event = "User",
    --         pattern = "CybuOpen",
    --         command = function()
    --             vim.notify("hi")
    --         end
    --     },
    --     {
    --         event = "User",
    --         pattern = "CybuClose",
    --         command = function()
    --             vim.notify("hi")
    --         end
    --     }
    -- )
end

init()

return M
