local P = {}

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")
local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_set = require "telescope.actions.set"
local action_state = require("telescope.actions.state")
local utils = require("telescope.utils")

local Job = require("plenary.job")
local scan = require "plenary.scandir"

local color = require("common.color")

P.use_highlighter = true

---Choose a folder and then grep in it
---@param opts table
P.live_grep_in_folder = function(opts)
    opts = opts or {}
    local data = {}
    scan.scan_dir(
        vim.loop.cwd(),
        {
            hidden = opts.hidden,
            only_dirs = true,
            respect_gitignore = opts.respect_gitignore,
            on_insert = function(entry)
                table.insert(data, entry .. "/")
            end
        }
    )
    table.insert(data, 1, "." .. "/")

    pickers.new(
        opts,
        {
            prompt_title = "Folders for Live Grep",
            finder = finders.new_table {results = data, entry_maker = make_entry.gen_from_file(opts)},
            previewer = conf.file_previewer(opts),
            sorter = conf.file_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                action_set.select:replace(
                    function()
                        local current_picker = action_state.get_current_picker(prompt_bufnr)
                        local dirs = {}
                        local selections = current_picker:get_multi_selection()
                        if vim.tbl_isempty(selections) then
                            table.insert(dirs, action_state.get_selected_entry().value)
                        else
                            for _, selection in ipairs(selections) do
                                table.insert(dirs, selection.value)
                            end
                        end
                        -- Initial mode as insert isn't working
                        actions._close(prompt_bufnr, current_picker.initial_mode == "insert")
                        require("telescope.builtin").live_grep {search_dirs = dirs, initial_mode = "insert"}
                    end
                )
                return true
            end
        }
    ):find()
end

---List current windows
---@param opts table
P.windows = function(opts)
    opts = opts or {}
    local results = {}

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if name and name ~= "" then
            table.insert(results, {win, name})
        end
    end

    pickers.new(
        opts,
        {
            prompt_title = "Windows",
            finder = finders.new_table {
                results = results,
                entry_maker = function(line)
                    return {
                        ordinal = line[2],
                        value = line[1],
                        display = line[2],
                        path = line[2] or ""
                    }
                end
            },
            sorter = conf.generic_sorter(opts),
            previewer = previewers.cat.new(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(
                    function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        vim.api.nvim_set_current_win(selection.value)
                    end
                )
                return true
            end
        }
    ):find()
end

---Wrapper for `:scriptnames`
---@param opts table
P.scriptnames = function(opts)
    opts = opts or {}
    local results = {}

    opts.path_display = {"smart"}
    opts.layout_config = {preview_width = 0.4}

    local snames = api.nvim_command_output("scriptnames")
    snames = vim.split(snames, "\n")
    local bufnr = api.nvim_get_current_buf()

    for i = #snames - 1, 2, -1 do
        local n, filename = snames[i]:match("(%d+):%s+(.*)")
        table.insert(
            results,
            {
                bufnr = tonumber(bufnr),
                scriptn = n,
                filename = filename
            }
        )
    end

    local displayer =
        entry_display.create {
        separator = "▏",
        items = {
            {width = 4},
            {remaining = true}
        }
    }

    local make_display = function(entry)
        local filename = utils.transform_path(opts, entry.filename)
        return displayer {
            {entry.scriptn, "WarningMsg"},
            filename
        }
    end

    pickers.new(
        opts,
        {
            prompt_title = "scriptnames",
            path_display = "shorten",
            finder = finders.new_table {
                results = results,
                entry_maker = function(e)
                    return {
                        value = e,
                        display = make_display,
                        ordinal = e.scriptn,
                        bufnr = e.bufnr,
                        scriptn = e.scriptn,
                        filename = e.filename
                    }
                end
            },
            sorter = conf.generic_sorter(opts),
            previewer = conf.file_previewer(opts)
        }
    ):find()
end

---Show file changes
---@param opts table
P.changes = function(opts)
    opts = opts or {}
    local results = {}

    -- local default = require("telescope.themes")["get_ivy"](opts)
    -- opts = vim.tbl_deep_extend("force", opts, default)

    local changes = api.nvim_command_output("changes")
    changes = vim.split(changes, "\n")
    local bufnr = api.nvim_get_current_buf()

    for i = #changes - 1, 3, -1 do
        local change, line, col, text = changes[i]:match("(%d+)%s+(%d+)%s+(%d+)%s+(.*)")
        table.insert(
            results,
            {
                bufnr = tonumber(bufnr),
                change = change,
                lnum = tonumber(line),
                col = tonumber(col),
                text = text,
                filename = api.nvim_buf_get_name(bufnr)
            }
        )
    end

    local displayer =
        entry_display.create {
        separator_hl = "SpellCap",
        separator = "▏",
        items = {
            {width = 4}, -- change
            {width = 5}, -- line
            {width = 3}, -- col
            {remaining = true} -- text
        }
    }

    local make_display = function(entry)
        return displayer {
            {entry.change, "WarningMsg"},
            {entry.lnum, "SpellCap"},
            {entry.col, "ErrorMsg"},
            entry.text
        }
    end

    pickers.new(
        opts,
        {
            prompt_title = "Changes",
            finder = finders.new_table {
                results = results,
                -- entry_maker = make_entry.gen_from_quickfix(opts)
                entry_maker = function(e)
                    return {
                        value = e,
                        display = make_display,
                        ordinal = e.change,
                        bufnr = e.bufnr,
                        change = e.change,
                        lnum = e.lnum,
                        col = e.col,
                        text = e.text,
                        filename = e.filename
                    }
                end
            },
            sorter = conf.generic_sorter(opts),
            previewer = conf.qflist_previewer(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(
                    function()
                        local sel = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        api.nvim_win_set_cursor(0, {sel.lnum, sel.col})
                    end
                )
                return true
            end
        }
    ):find()
end

---Testing function
P.XXX = function(opts)
    opts = opts or {}
    pickers.new(
        opts,
        {
            prompt_title = "colors",
            finder = finders.new_table {
                results = {"red", "green", "blue"}
            },
            sorter = conf.generic_sorter(opts),
            attach_mapping = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        -- print(vim.inspect(selection))
                        vim.api.nvim_put({selection[1]}, "", false, true)
                    end
                )
                return true
            end
        }
    ):find()
end

-- ============================== Unused ==============================
-- ====================================================================

-- Error: nvim_buf_is_valid must not be called ...
P.find = function(opts)
    opts = opts or {}

    local sfs =
        finders._new {
        fn_command = function(_, prompt)
            if opts.cwd then
                vim.cmd("cd " .. opts.cwd)
            end
            local prefix = (vim.fn.getcwd()) .. ".*"

            local args = {
                "-ptf",
                prefix .. (opts.pattern or "")
            }

            if opts.path then
                table.insert(args, opts.path)
            end

            return {
                writer = Job:new {
                    command = "fd",
                    args = args
                },
                command = "fzy",
                args = {"-e", prompt}
            }
        end,
        entry_maker = make_entry.gen_from_file(opts)
    }

    pickers.new(
        opts,
        {
            prompt_title = "fd + fzy",
            finder = sfs,
            -- previewer = previewers.cat.new(opts),
            previewer = R("telescope.previewers").cat.new(opts),
            sorter = P.use_highlighter and sorters.highlighter_only(opts)
        }
    ):find()
end

P.fzf = function(opts)
    opts = opts or {}
    pickers.new(
        opts,
        {
            prompt_title = "Telefzf",
            finder = finders.new_job(
                function(prompt)
                    return {"telefzf", prompt}
                    -- end, make_entry.gen_from_vimgrep(opts), 1000, vim.loop.cwd()),
                    -- end, make_entry.gen_from_string(), 1000, vim.loop.cwd()),
                end,
                function(x)
                    return setmetatable(
                        {},
                        {
                            __index = function()
                                return x
                            end
                        }
                    )
                end,
                1000,
                vim.loop.cwd()
            ),
            previewer = conf.file_previewer(opts),
            sorter = sorters.highlighter_only(opts)
        }
    ):find()
end

return P
