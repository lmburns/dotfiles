---@module 'plugs.legendary'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local legend = F.npcall(require, "legendary")
if not legend then
    return
end

function M.setup()
    legend.setup({
        -- Initial keymaps to bind
        keymaps = {},
        -- Initial commands to bind
        commands = {},
        -- Initial augroups/autocmds to bind
        autocmds = {},
        -- Initial functions to bidn
        funcs = {},
        -- default opts to merge with the `opts` table
        -- of each individual item
        default_opts = {
            keymaps = {},
            commands = {},
            autocmds = {},
        },
        -- Customize the prompt that appears on your vim.ui.select() handler
        -- Can be a string or a function that returns a string.
        select_prompt = " Legendary ",
        -- Character to use to separate columns in the UI
        col_separator_char = "│",
        -- Optionally pass a custom formatter function. This function
        -- receives the item as a parameter and the mode that legendary
        -- was triggered from (e.g. `function(item, mode): string[]`)
        -- and must return a table of non-nil string values for display.
        -- It must return the same number of values for each item to work correctly.
        -- The values will be used as column values when formatted.
        -- See function `default_format(item)` in
        -- `lua/legendary/ui/format.lua` to see default implementation.
        default_item_formatter = nil,
        -- Include builtins by default, set to false to disable
        include_builtin = false,
        -- Include the commands that legendary.nvim creates itself
        -- in the legend by default, set to false to disable
        include_legendary_cmds = false,
        -- Sort most recently used items to the top of the list
        -- so they can be quickly re-triggered when opening legendary again
        most_recent_items_at_top = true,
        which_key = {
            -- Automatically add which-key tables to legendary
            -- see ./doc/WHICH_KEY.md for more details
            auto_register = true,
            -- you can put which-key.nvim tables here,
            -- or alternatively have them auto-register,
            -- see ./doc/WHICH_KEY.md
            mappings = {},
            opts = {},
            -- controls whether legendary.nvim actually binds they keymaps,
            -- or if you want to let which-key.nvim handle the bindings.
            -- if not passed, true by default
            do_binding = false,
        },
        scratchpad = {
            -- How to open the scratchpad buffer,
            -- 'current' for current window, 'float'
            -- for floating window
            view = "float",
            -- How to show the results of evaluated Lua code.
            -- 'print' for `print(result)`, 'float' for a floating window.
            results_view = "float",
            -- Border style for floating windows related to the scratchpad
            float_border = "rounded",
            -- Whether to restore scratchpad contents from a cache file
            keep_contents = true,
        },
        -- Directory used for caches
        cache_path = ("%s/legendary/"):format(lb.dirs.cache),
        extensions = {
            diffview = true,
        },
    })
end

local function init()
    M.setup()

    local filters = require("legendary.filters")

    -- https://github.com/mrjones2014/legendary.nvim/blob/master/doc/USAGE_EXAMPLES.md
    -- NOTE: C-_ => C-/
    legend.keymaps(
        {
            {
                "<C-_>",
                function()
                    legend.find({filters = {filters.mode("n"), filters.keymaps()}})
                end,
                description = "Legendary: keymaps (normal)",
                mode = "n",
            },
            {
                "<C-_>",
                function()
                    legend.find({filters = {filters.mode("i"), filters.keymaps()}})
                end,
                description = "Legendary: keymaps (insert)",
                mode = "i",
            },
            {
                "<C-_>",
                function()
                    legend.find({filters = {filters.mode("x"), filters.keymaps()}})
                end,
                description = "Legendary: keymaps (visual)",
                mode = "x",
            },
            {
                "<C-_>",
                function()
                    legend.find({filters = {filters.mode("o"), filters.keymaps()}})
                end,
                description = "Legendary: keymaps (operator)",
                mode = "o",
            },
            -- legend.find({filters = {filters.commands()}})
        }
    )
end

init()

return M
