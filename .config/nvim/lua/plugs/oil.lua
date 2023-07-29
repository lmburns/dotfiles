---@module 'plugs.oil'
local M = {}

local F = Rc.F
local oil = F.npcall(require, "oil")
if not oil then
    return
end

local map = Rc.api.map
local command = Rc.api.command
local hl = Rc.shared.hl
local utils = Rc.shared.utils
-- local log = Rc.lib.log

local fn = vim.fn
local cmd = vim.cmd

local previous = {
    url = nil,
    dir = nil,
    buf = nil,
}

M.toggle = (function()
    local is_open = false
    return function()
        if is_open and require("oil.util").is_oil_bufnr(0) then
            api.nvim_win_close(0, true)
            is_open = false
        else
            is_open = true
            cmd.Oil({mods = {vertical = true}})
            local buf = api.nvim_get_current_buf()
            local win = api.nvim_get_current_win()
            map("n", "qq", "<Cmd>close<CR>", {buffer = buf})

            -- vim.defer_fn(function()
            api.nvim_win_call(win, function()
                -- promise:new(function()
                --     return utils.longest_line(buf)
                -- end):thenCall(function(count)
                -- end)

                local count = utils.longest_line(buf)
                cmd.wincmd({"|", count = count})
                vim.wo.winfixwidth = true
            end)
            -- end, 1)
        end
    end
end)()

local function toggle_detail()
    local config = require("oil.config")
    if #config.columns == 1 then
        oil.set_columns({"icon", "permissions", "size", "mtime"})
    else
        oil.set_columns({"icon"})
    end
end
local function undo_deletion()
    fn.system("rip -u")
    cmd.redraw()
end
local function cd_last_dir()
    if fn.isdirectory(previous.dir) == 1 or api.nvim_buf_is_loaded(previous.buf) then
        oil.open(previous.dir)
    end
end

function M.setup()
    oil.setup({
        -- Id is automatically added at the beginning, and name at the end
        -- See :help oil-columns
        columns = {
            "icon",
            -- "permissions",
            "size",
            -- "mtime",
        },
        -- Buffer-local options to use for oil buffers
        buf_options = {
            buflisted = false,
            bufhidden = "hide",
        },
        -- Window-local options to use for oil buffers
        win_options = {
            signcolumn = "no",
            cursorcolumn = false,
            foldcolumn = "0",
            wrap = false,
            spell = false,
            list = false,
            conceallevel = 3,
            concealcursor = "n",
        },
        -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`
        default_file_explorer = true,
        -- Restore window options to previous values when leaving an oil buffer
        restore_win_options = true,
        -- Skip the confirmation popup for simple operations
        skip_confirm_for_simple_edits = false,
        -- Deleted files will be removed with the trash_command (below).
        trash = false,
        delete_to_trash = true,
        -- Change this to customize the command used when deleting to trash
        trash_command = "rip",
        -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
        prompt_save_on_select_new_entry = true,
        -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
        -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
        -- Additionally, if it is a string that matches "actions.<name>",
        -- it will use the mapping at require("oil.actions").<name>
        -- Set to `false` to remove a keymap
        -- See :help oil-actions for a list of all available actions
        keymaps = {
            ["g?"] = "actions.show_help",
            [";h"] = {
                desc = "Open home directory",
                callback = F.ithunk(cmd, "edit $HOME"),
            },
            [";v"] = {
                desc = "Open nvim directory",
                callback = F.ithunk(cmd, "edit $XDG_CONFIG_HOME/nvim/lua"),
            },

            -- ["qq"] = "actions.close",
            ["q;"] = "actions.close",
            ["Q"] = "actions.close",
            ["<C-c>"] = "actions.close",
            ["<C-g>"] = "actions.refresh",
            ["<CR>"] = "actions.select",
            ["<C-s>"] = "actions.select_vsplit",
            ["<C-h>"] = "actions.select_split",
            ["<C-t>"] = "actions.select_tab",
            ["<C-y>"] = "actions.preview",
            ["<C-f>"] = "actions.preview_scroll_down",
            ["<C-b>"] = "actions.preview_scroll_up",
            ["yf"] = "actions.copy_entry_path",
            ["K"] = "actions.preview",

            ["_"] = "actions.open_cwd",
            ["-"] = "actions.parent",
            ["<BS>"] = {desc = "Cd last directory", callback = F.ithunk(cd_last_dir)},
            ["`"] = "actions.lcd",
            ["~"] = "actions.tcd",

            ["<Leader>t"] = "actions.open_terminal",
            ["g."] = "actions.toggle_hidden",
            ["g:"] = "actions.open_cmdline",

            ["du"] = {
                desc = "Undo file deletion",
                callback = F.ithunk(undo_deletion),
            },
            ["g,"] = {
                desc = "Toggle detail view",
                callback = F.ithunk(toggle_detail),
            },
            ["gd"] = {
                desc = "Toggle detail view",
                callback = F.ithunk(toggle_detail),
            },
        },
        -- Set to false to disable all of the above keymaps
        use_default_keymaps = false,
        view_options = {
            -- Show files and directories that start with "."
            show_hidden = true,
            -- This function defines what is considered a "hidden" file
            is_hidden_file = function(name, _bufnr)
                return vim.startswith(name, ".")
            end,
            -- This function defines what will never be shown, even when `show_hidden` is set
            is_always_hidden = function(_name, _bufnr)
                return false
            end,
        },
        -- Configuration for the floating window in oil.open_float
        float = {
            -- Padding around the floating window
            padding = 2,
            max_width = 0,
            max_height = 0,
            border = Rc.style.border,
            win_options = {
                winblend = 10,
            },
            -- This is the config that will be passed to nvim_open_win.
            -- Change values here to customize the layout
            override = function(conf)
                return conf
            end,
        },
        -- Configuration for the actions floating preview window
        preview = {
            width = nil,
            height = nil,
            -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
            max_width = 0.9,
            -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
            min_width = {40, 0.4},
            -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
            max_height = 0.9,
            -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
            min_height = {5, 0.1},
            -- optionally define an integer/float for the exact height of the preview window
            border = Rc.style.border,
            win_options = {
                winblend = 0,
            },
        },
        -- Configuration for the floating progress window
        progress = {
            max_width = 0.9,
            min_width = {40, 0.4},
            width = nil,
            max_height = {10, 0.9},
            min_height = {5, 0.1},
            height = nil,
            border = Rc.style.border,
            minimized_border = "none",
            win_options = {
                winblend = 0,
            },
        },
    })
end

local function init()
    cmd.packadd("oil.nvim")

    M.setup()

    hl.plugin("Oil", {
        OilDir = {link = "Directory"},
        OilSocket = {link = "Function"},
        OilLink = {link = "Special"},
        OilFile = {link = "Conditional"},
        OilCreate = {link = "@type"},
        OilDelete = {link = "@text.error"},
        OilMove = {link = "@bold"},
        OilCopy = {link = "@macro"},
        OilChange = {link = "@text.warn"},
    })

    map("n", "<Leader>wu", oil.toggle_float, {desc = "Oil: toggle float"})
    map("n", "qU", "<Cmd>Oil<CR>", {desc = "Oil: toggle fullscreen"})
    map("n", "qu", M.toggle, {desc = "Oil: open vertical"})

    -- exe min([winwidth('%'),line('$')]).'wincmd _'<Bar>setl winfixheight
    command("OilEmptyTrash", oil.empty_trash, {nargs = 0, desc = "Empty trash"})

    nvim.autocmd.lmb__Oil = {
        {
            event = "BufLeave",
            pattern = "oil://*",
            nested = true,
            command = function(a)
                local url = api.nvim_buf_get_name(a.buf)
                previous.url = url
                previous.dir = url:gsub("oil://", "")
                previous.buf = a.buf
            end,
        },
    }
end

init()

return M
