local M = {}

-- TODO: Set this up
-- The problem is that which-key needs to be loaded afterwards
-- If which-key is specified to be loaded afterwards, then which-key
-- is unable to be used in any file in the configuration setup.

function M.setup()
    require("legendary").setup(
        {
            -- Include builtins by default, set to false to disable
            include_builtin = false,
            -- Include the commands that legendary.nvim creates itself
            -- in the legend by default, set to false to disable
            include_legendary_cmds = false,
            -- Customize the prompt that appears on your vim.ui.select() handler
            -- Can be a string or a function that takes the `kind` and returns
            -- a string. See "Item Kinds" below for details. By default,
            -- prompt is 'Legendary' when searching all items,
            -- 'Legendary Keymaps' when searching keymaps,
            -- 'Legendary Commands' when searching commands,
            -- and 'Legendary Autocmds' when searching autocmds.
            select_prompt = function(kind)
                if kind == "legendary.items" then
                    return " Legendary "
                end

                -- Convert kind to Title Case (e.g. legendary.keymaps => Legendary Keymaps)
                return " " .. string.gsub(" " .. kind:gsub("%.", " "), "%W%l", string.upper):sub(2) .. " "
            end,
            -- Optionally pass a custom formatter function. This function
            -- receives the item as a parameter and must return a table of
            -- non-nil string values for display. It must return the same
            -- number of values for each item to work correctly.
            -- The values will be used as column values when formatted.
            -- See function `get_default_format_values(item)` in
            -- `lua/legendary/formatter.lua` to see default implementation.
            formatter = nil,
            -- When you trigger an item via legendary.nvim,
            -- show it at the top next time you use legendary.nvim
            most_recent_item_at_top = true,
            -- Initial keymaps to bind
            keymaps = {},
            -- Initial commands to bind
            commands = {},
            -- Initial augroups and autocmds to bind
            autocmds = {},
            -- which_key = {
            --     -- you can put which-key.nvim tables here,
            --     -- or alternatively have them auto-register,
            --     -- see section on which-key integration
            --     mappings = {},
            --     opts = {}
            -- },
            -- Automatically add which-key tables to legendary
            -- see "which-key.nvim Integration" below for more details
            auto_register_which_key = true,
            -- settings for the :LegendaryScratch command
            scratchpad = {
                -- configure how to show results of evaluated Lua code,
                -- either 'print' or 'float'
                -- Pressing q or <ESC> will close the float
                display_results = "float"
            }
        }
    )
end

-- local keymaps = {
--   { '<C-d>', description = 'Scroll docs up' },
--   { '<C-f>', description = 'Scroll docs down' },
-- }

-- local commands = {
--   {
--     ":MyCommand {some_argument}<CR>",
--     description = "Command with argument",
--     unfinished = true,
--   },
--   -- or
--   {
--     ":MyCommand [some_argument]<CR>",
--     description = "Command with argument",
--     unfinished = true,
--   },
-- }

local function init()
    M.setup()
    local wk = require("which-key")

    require("legendary").bind_keymap(
        {
            "<C-,>",
            "<Cmd>Legendary keymaps<CR>",
            description = "Show Legendary keymaps",
            mode = {"n", "i", "x"}
        }
    )
end

init()

return M
