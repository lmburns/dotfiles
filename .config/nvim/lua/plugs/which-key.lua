local M = {}

local wk = require("which-key")
local utils = require("common.utils")
local map = utils.map

function M.setup()
    -- TODO: Get '?' to map to popup for current operator
    -- FIX: gc operator

    -- Workaround until WhichKey has autocmds to disable it for certain filetypes
    local show = wk.show
    wk.show = function(keys, opts)
        if vim.bo.ft == "TelescopePrompt" or vim.bo.ft == "toggleterm" then
            return
        end
        show(keys, opts)
    end

    local presets = require("which-key.plugins.presets")
    presets.operators["gc"] = "Commenter"
    -- presets.operators["d"] = nil
    presets.operators['"_d'] = "Delete blackhole"
    presets.operators["s"] = "Substitute"

    wk.setup {
        plugins = {
            marks = true, -- shows a list of your marks on ' and `
            registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            spelling = {
                enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                suggestions = 20 -- how many suggestions should be shown in the list?
            },
            presets = {
                -- adds help for a bunch of default keybindings
                operators = true, -- adds help for operators like d, y, ... and registers them for motion
                motions = true, -- adds help for motions
                text_objects = true, -- help for text objects triggered after entering an operator
                windows = true, -- default bindings on <c-w>
                nav = true, -- misc bindings to work with windows
                z = true, -- bindings for folds, spelling and others prefixed with z
                g = true -- bindings for prefixed with g
            }
        },
        -- NOTE: These are not added
        operators = {
            -- add operators that will trigger motion and text object completion
            -- gc = "Comments",
            -- ['"_'] = "Blackhole",
            -- s = "Substitute",
            -- ['"_d'] = "Delete (blackhole)",
            ["d"] = "Delete Me"
        },
        key_labels = {},
        icons = {
            breadcrumb = "»", -- symbol used in the command line area that shows active key combo
            separator = "➜", -- symbol used between a key and it's label
            group = "+" -- symbol prepended to a group
        },
        popup_mappings = {
            scroll_down = "<c-d>", -- binding to scroll down inside the popup
            scroll_up = "<c-u>" -- binding to scroll up inside the popup
        },
        window = {
            border = "rounded", -- none, single, double, shadow
            position = "bottom", -- bottom, top
            margin = {1, 0, 1, 0}, -- extra window margin [top, right, bottom, left]
            padding = {2, 2, 2, 2}, -- extra window padding [top, right, bottom, left]
            winblend = 0
        },
        layout = {
            height = {min = 4, max = 25}, -- min and max height of the columns
            width = {min = 20, max = 50}, -- min and max width of the columns
            spacing = 3, -- spacing between columns
            align = "left" -- align columns left, center or right
        },
        -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
        hidden = {"lua", "^ ", "<silent>"}, -- hide mapping boilerplate
        show_help = true, -- show help message on the command line when the popup is visible
        triggers_nowait = {}, -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
        triggers = "auto",
        triggers_blacklist = {
            i = {"j", "k"},
            v = {"j", "k"},
            n = {"o", "O", "ga"}, -- Would be nice if two letter worked
        }
    }

    wk.register(
        {
            ["d"] = {[["_d]], "Delete"}
        },
        {auto = true, mode = "n"}
    )
end

local function init()
    -- cmd([[highlight default link WhichKey          htmlH1]])
    -- cmd([[highlight default link WhichKeySeperator String]])
    -- cmd([[highlight default link WhichKeyGroup     Keyword]])
    -- cmd([[highlight default link WhichKeyDesc      Include]])
    -- cmd([[highlight default link WhichKeyFloat     CursorLine]])
    -- cmd([[highlight default link WhichKeyValue     Comment]])

    M.setup()

    map("v", "<Leader>wh", "<Esc><Cmd>WhichKey '' v<CR>")

    wk.register(
        {
            ["<Leader>wh"] = {"<Cmd>WhichKey '' n<CR>", "WhichKey normal mode"},
            ["<Leader><Leader><CR>"] = {[[<Cmd>WhichKey \ \ <CR>]], "WhichKey Leader Leader"},
            ["<Leader><CR>"] = {[[<Cmd>WhichKey \ <CR>]], "WhichKey Leader"},
            ["<LocalLeader><CR>"] = {"<Cmd>WhichKey <LocalLeader><CR>", "WhichKey LocalLeader"},
            [";<CR>"] = {"<Cmd>WhichKey ;<CR>", "WhichKey colon"},
            ["g<CR>"] = {"<Cmd>WhichKey g<CR>", "WhichKey g"},
            ["[<CR>"] = {"<Cmd>WhichKey [<CR>", "WhichKey ["},
            ["]<CR>"] = {"<Cmd>WhichKey ]<CR>", "WhichKey ]"},
            ["<C-x><CR>"] = {"<Cmd>WhichKey ]<CR>", "WhichKey <C-x>"},
            ["c<CR>"] = {[[<Cmd>WhichKey c<CR>]], "WhichKey c"},
            ["<C-w><CR>"] = {[[<Cmd>WhichKey <C-w><CR>]], "WhichKey <C-w>"},
            ["q<CR>"] = {[[<Cmd>WhichKey q<CR>]], "WhichKey q"},
            ["z<CR>"] = {[[<Cmd>WhichKey z<CR>]], "WhichKey z"}
        }
    )

    -- XXX: Workaround until custom operator gets fixed
    wk.register(
        {
            ["?"] = {"<Cmd>WhichKey d<CR>", "WhichKey operator"}
        },
        {mode = "o"}
    )

    -- map(
    --     "n",
    --     "gc",
    --     function()
    --         require("which-key").show("d", {mode = "gc", prefix = "", auto = true})
    --         -- cmd [["_d]]
    --     end
    -- )
end

init()

return M
