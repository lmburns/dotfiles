local M = {}

local D = require("dev")

local utils = require("common.utils")
local map = utils.map

local w = vim.wo
local g = vim.g
local cmd = vim.cmd

function M.setup_twighlight()
    local twilight = D.npcall(require, "twilight")
    if not twilight then
        return
    end
    twilight.setup {
        dimming = {
            alpha = 0.25, -- amount of dimming
            -- we try to get the foreground from the highlight groups or fallback color
            color = {"Normal", "#ffffff"},
            inactive = false -- when true, other windows will be fully dimmed (unless they contain the same buffer)
        },
        context = 10, -- amount of lines we will try to show around the current line
        treesitter = true, -- use treesitter when available for the filetype
        -- treesitter is used to automatically expand the visible text,
        -- but you can further control the types of nodes that should always be fully expanded
        expand = {
            -- for treesitter, we we always try to expand to the top-most ancestor with these types
            "function",
            "method",
            "table",
            "if_statement"
        },
        exclude = {} -- exclude these filetypes
    }
end

function M.setup_zenmode()
    local zen = D.npcall(require, "zen-mode")
    if not zen then
        return
    end

    zen.setup {
        window = {
            backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
            -- height and width can be:
            -- * an absolute number of cells when > 1
            -- * a percentage of the width / height of the editor when <= 1
            -- * a function that returns the width or the height
            width = 120, -- width of the Zen window
            height = 1, -- height of the Zen window
            -- by default, no options are changed for the Zen window
            -- uncomment any of the options below, or add other vim.wo options you want to apply
            options = {}
        },
        plugins = {
            -- disable some global vim options (vim.o...)
            -- comment the lines to not apply the options
            options = {
                enabled = true,
                ruler = true, -- disables the ruler text in the cmd line area
                showcmd = false -- disables the command in the last line of the screen
            },
            twilight = {enabled = true}, -- enable to start Twilight when zen mode opens
            gitsigns = {enabled = true}, -- disables git signs
            tmux = {enabled = true}, -- disables the tmux statusline
            kitty = {
                enabled = false,
                font = "+4" -- font size increment
            }
        },
        -- callback where you can add custom code when the Zen window opens
        ---@diagnostic disable:unused-local
        on_open = function(win)
            g.indent_blankline_enabled = false
            w.foldlevel = 99
            w.statusline = [[...%(\ [%M%R%H]%)]]
            cmd("let &background = &background")
            require("scrollbar.utils").hide()
        end,
        -- callback where you can add custom code when the Zen window closes
        on_close = function()
            cmd("let &background = &background")
            require("scrollbar.utils").show()
        end
    }
end

local function init()
    M.setup_twighlight()
    M.setup_zenmode()

    map("n", "<Leader>li", ":Twilight<CR>")
    map("n", "<Leader>zm", ":ZenMode<CR>")
end

init()

return M
