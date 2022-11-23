local M = {}

local D = require("dev")
local wk = D.npcall(require, "which-key")
if not wk then
    return
end

local style = require("style")
local utils = require("common.utils")
local map = utils.map

function M.setup()
    -- Workaround until WhichKey has autocmds to disable it for certain filetypes
    local show = wk.show
    wk.show = function(keys, opts)
        if vim.bo.ft == "TelescopePrompt" or vim.bo.ft == "toggleterm" or vim.b.visual_multi then
            return
        end
        show(keys, opts)
    end

    -- local presets = require("which-key.plugins.presets")
    -- presets.operators["gc"] = "Commenter"
    -- presets.operators["d"] = nil
    -- presets.operators['"_d'] = "Delete blackhole"
    -- presets.operators["s"] = "Substitute"

    wk.setup {
        plugins = {
            marks = true, -- shows a list of your marks on ' and `
            registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
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
        -- NOTE: Only gq works here
        operators = {
            -- add operators that will trigger motion and text object completion
            gq = "Format",
            y = "Yank",
            gc = "Comments",
            ga = "Easy align",
            ys = "Surround",
            -- s = "Substitute",
            ['"_d'] = "Delete"
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
            border = style.current.border, -- none, single, double, shadow
            position = "bottom", -- bottom, top
            margin = {1, 0, 1, 0}, -- extra window margin [top, right, bottom, left]
            padding = {2, 2, 2, 2}, -- extra window padding [top, right, bottom, left]
            winblend = 10
        },
        layout = {
            height = {min = 4, max = 25}, -- min and max height of the columns
            width = {min = 20, max = 50}, -- min and max width of the columns
            spacing = 3, -- spacing between columns
            align = "left" -- align columns left, center or right
        },
        -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
        hidden = {"lua", "^ ", "<silent>", "<cmd> ", "<Cmd> ", "<cmd>", "<Cmd>", "<CR>"}, -- hide mapping boilerplate
        show_help = true, -- show help message on the command line when the popup is visible
        ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
        triggers_nowait = {}, -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
        triggers = "auto",
        triggers_blacklist = {
            i = {"j", "k"},
            v = {"j", "k"},
            c = {},
            n = {"s"}
            -- o = {"d", '"_d'}
        }
    }
end

local function wk_help()
    return wk.show_command("", utils.mode())
end

local function init()
    M.setup()

    -- map("n", "d", [[:lua require("which-key").show('"_d', {mode = "n", auto = true})<CR>]])
    map("n", "d", '"_d', {desc = "Delete blackhole"})
    map("i", "<C-A-w>", "<Esc><Cmd>WhichKey '' i<CR>")
    map("v", "<Leader>wh", "<Esc><Cmd>WhichKey '' v<CR>")

    -- The reason why some of these are here is because they don't always trigger (some never do)
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
            ["'<CR>"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
            ["''"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
            ["z<CR>"] = {[[<Cmd>WhichKey z<CR>]], "WhichKey z"},
            ["s<CR>"] = {[[<Cmd>WhichKey s<CR>]], "WhichKey s"},
            ["cr<CR>"] = {[[<Cmd>WhichKey cr<CR>]], "WhichKey cr"},
            ["gc<CR>"] = {[[<Cmd>WhichKey gc<CR>]], "WhichKey gc"},
            ["ga<CR>"] = {[[<Cmd>WhichKey ga<CR>]], "WhichKey ga"}
        }
    )

    -- Addition to builtin which-key
    wk.register(
        {
            ["gq"] = "Format operator",
            ["zW"] = "Mark word as bad internal wordlist",
            ["zuw"] = "Remove from spellfile",
            ["zuW"] = "Remove from internal wordlist",
            ["zug"] = "Remove from spellfile",
            ["zuG"] = "Remove from internal wordlist",
            ["zQ"] = "Equivalent to ':q!'",
            ["zG"] = "Add word to internal spell-list",
            ["zd"] = "Delete one fold at the cursor",
            ["zD"] = "Delete folds recursively",
            ["zE"] = "Eliminate all folds",
            ["zf"] = "Operator to create fold",
            ["zF"] = "Create fold for [count] lines",
            ["zX"] = "Undo manual folds, reapply foldlevel",
            ["zn"] = "Fold none, open all folds",
            ["zN"] = "Fold normal, all folds remain",
            ["zi"] = "Invert 'foldenable'"
        }
    )

    wk.register(
        {
            ["<C-w>"] = {
                name = "+window",
                ["<C-r>"] = "Rotate window down/right",
                r = "Rotate window down/right",
                R = "Rotate window up/left",
                K = "Move current window to top",
                J = "Move current window to bottom",
                H = "Move current window to left",
                L = "Move current window to right"
            }
        }
    )

    -- <F-3> to show which-key help in any relevant mode
    local _modes = {"n", "i", "t", "v", "x", "o"}
    for m = 1, #_modes do
        wk.register({["<F3>"] = {wk_help, "Show which-key help menu", noremap = true}}, {mode = _modes[m]})
    end

    -- Workaround until custom operator gets fixed
    wk.register(
        {
            ["?"] = {"<Cmd>WhichKey '' o<CR>", "WhichKey operator"}
        },
        {mode = "o"}
    )
end

init()

return M
