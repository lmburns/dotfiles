---@module 'plugs.dressing'
local M = {}

local F = Rc.F
local dressing = F.npcall(require, "dressing")
if not dressing then
    return
end

local lazy = require("usr.lazy")
local themes = lazy.require("telescope.themes")
local icons = Rc.icons

function M.setup()
    dressing.setup({
        input = {
            -- Set to false to disable the vim.ui.input implementation
            enabled = true,
            -- Default prompt string
            default_prompt = ("%s "):format(icons.chevron.right),
            -- Can be 'left', 'right', or 'center'
            prompt_align = "left",
            -- When true, <Esc> will close the modal
            insert_only = true,
            -- When true, input will start in insert mode.
            start_in_insert = true,
            -- These are passed to nvim_open_win
            anchor = "SW",
            border = Rc.style.border,
            -- 'editor' and 'win' will default to being centered
            relative = "cursor",
            -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            prefer_width = 40,
            width = nil,
            -- min_width and max_width can be a list of mixed types.
            -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
            max_width = {140, 0.9},
            min_width = {20, 0.2},
            buf_options = {
                swapfile = false,
            },
            win_options = {
                winblend = 10,
                wrap = false,
                cursorline = false,
                linebreak = true,
                showbreak = "NONE",
                conceallevel = 0,
                winhighlight = {
                    FloatBorder = "FloatBorder",
                    FloatTitle = "Title",
                },
            },
            override = function(conf)
                -- This is the config that will be passed to nvim_open_win.
                -- Change values here to customize the layout
                return conf
            end,
            -- see :help dressing_get_config
            get_config = nil,
        },
        select = {
            -- Set to false to disable the vim.ui.select implementation
            enabled = true,
            -- Priority list of preferred vim.select implementations
            backend = {"telescope", "fzf_lua", "fzf", "builtin", "nui"},
            -- Options for telescope selector
            -- These are passed into the telescope picker directly. Can be used like:
            telescope = themes.get_dropdown({}),
            -- telescope = require('telescope.themes').get_ivy({}),
            -- telescope = require("telescope.themes").get_cursor({}),

            fzf = {window = {width = 0.5, height = 0.4}},
            fzf_lua = {winopts = {width = 0.5, height = 0.4}},
            nui = {
                size = nil,
                relative = "editor",
                position = "50%",
                border = {style = Rc.style.border},
                buf_options = {
                    swapfile = false,
                    filetype = "DressingSelect",
                },
                win_options = {
                    winblend = 10,
                },
                max_width = 80,
                max_height = 40,
                min_width = 40,
                min_height = 10,
            },
            -- Options for built-in selector
            builtin = {
                -- These are passed to nvim_open_win
                anchor = "NW",
                border = Rc.style.border,
                -- 'editor' and 'win' will default to being centered
                relative = "editor",
                buf_options = {
                    backup = false,
                    swapfile = false,
                },
                win_options = {
                    winblend = 10,
                    wrap = false,
                    cursorline = false,
                    linebreak = true,
                    showbreak = "NONE",
                    conceallevel = 0,
                    winhighlight = {
                        FloatBorder = "FloatBorder",
                        FloatTitle = "Title",
                    },
                },
                -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                -- the min_ and max_ options can be a list of mixed types.
                -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
                width = nil,
                max_width = {140, 0.8},
                min_width = {40, 0.2},
                height = nil,
                max_height = 0.9,
                min_height = {10, 0.2},
                override = function(conf)
                    -- This is the config that will be passed to nvim_open_win.
                    -- Change values here to customize the layout
                    return conf
                end,
            },
            -- Used to override format_item. See :help dressing-format
            format_item_override = {},
            -- see :help dressing_get_config
            get_config = function(opts)
                -- center the picker for treesitter prompts
                if opts.kind == "codeaction" then
                    return {
                        backend = "telescope",
                        telescope = themes.get_cursor({}),
                    }
                end
            end,
        },
    })
end

local function init()
    M.setup()
end

init()

return M
