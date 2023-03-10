local M = {}

local D = require("dev")
local bufferline = D.npcall(require, "bufferline")
if not bufferline then
    return
end

-- local utils = require("common.utils")
local icons = require("style").icons
local hl = require("common.color")
local groups = require("bufferline.groups")
local dirs = require("common.global").dirs
local pithunk = D.pithunk

local fn = vim.fn
local api = vim.api

local diagnostics_signs = {
    error = icons.lsp.sb.error,
    warning = icons.lsp.sb.warn,
    hint = icons.lsp.sb.hint,
    info = icons.lsp.sb.info
}

---Filter out filetypes you don't want to see
local function custom_filter(bufnr, buf_nums)
    local bo = vim.bo[bufnr]

    local logs =
        D.filter(
        buf_nums,
        function(b)
            return vim.bo[b].ft == "log"
        end
    )
    if vim.tbl_isempty(logs) then
        return true
    end
    local tab_num = fn.tabpagenr()
    local last_tab = fn.tabpagenr("$")
    local is_log = bo.ft == "log"
    if last_tab == 1 then
        return true
    end

    if bo.ft == "qf" or bo.bt == "terminal" then
        return false
    end

    -- filter out by buffer name
    if _t({"", "[No Name]", "[dap-repl]"}):contains(fn.bufname(bufnr)) then
        return false
    end

    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
    -- return true
end

---Function to show diagnostics in the bufferline
---@return string
---@diagnostic disable-next-line:unused-local
local function diagnostics_indicator(_count, _level, diagnostics, _context)
    local result = {}
    for name, count in pairs(diagnostics) do
        if diagnostics_signs[name] and count > 0 then
            table.insert(result, ("%s%d"):format(diagnostics_signs[name], count))
        end
    end
    local str = table.concat(result, " ")
    return #str > 0 and str or ""
end

---Can be used to change the buffer's label in the bufferline.
---@param buf table contains a "name", "path" and "bufnr"
local function name_formatter(buf)
    -- Remove extension from markdown files for example
    if buf.name:match("%.md") then
        return fn.fnamemodify(buf.name, ":t:r")
    end
end

function M.setup()
    -- __TEST = true
    bufferline.setup(
        {
            options = {
                debug = {logging = true},
                -- navigation = {mode = "uncentered"},
                mode = "buffers",
                themable = true, -- whether or not bufferline highlights can be overridden externally
                numbers = function(opts)
                    return ("%s"):format(opts.raise(opts.ordinal))
                end,
                close_command = function(bufnr)
                    require("close_buffers").delete({type = bufnr})
                end, -- can be a string | function, see "Mouse actions"
                right_mouse_command = function(bufnr)
                    require("close_buffers").delete({type = bufnr})
                end, -- can be a string | function, see "Mouse actions"
                left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
                middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
                indicator = {style = "NONE"},
                buffer_close_icon = "",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                -- can also be a table containing 2 custom separators
                -- [focused and unfocused]. eg: { '|', '|' }
                separator_style = "slant",
                max_name_length = 20,
                max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
                tab_size = 20,
                -- name_formatter = nil,
                name_formatter = name_formatter,
                -- diagnostics = false,
                diagnostics = "coc", -- false
                diagnostics_indicator = diagnostics_indicator,
                diagnostics_update_in_insert = false,
                custom_filter = custom_filter,
                -- offsets = {
                --   {filetype = "NvimTree", text = "File Explorer", text_align = "left" | "center" | "right"}
                -- },
                offsets = {
                    {
                        text = "Undotree",
                        filetype = "undotree",
                        highlight = "PanelHeading",
                        separator = true
                    },
                    {
                        text = "DiffView",
                        filetype = "DiffviewFiles",
                        highlight = "PanelHeading",
                        separator = true
                    },
                    {
                        text = "Symbols",
                        filetype = "Outline",
                        highlight = "PanelHeading",
                        separator = true
                    },
                    {
                        text = " Packer",
                        filetype = "packer",
                        highlight = "PanelHeading",
                        separator = true
                    },
                    {
                        text = "Aerial",
                        filetype = "aerial",
                        text_align = "center",
                        highlight = "PanelHeading",
                        separator = true
                    },
                    {
                        text = "CocTree",
                        filetype = "coctree",
                        highlight = "PanelHeading",
                        separator = true
                    },
                    {
                        text = "Vista",
                        filetype = "vista",
                        highlight = "PanelHeading",
                        separator = true
                    }
                },
                color_icons = true,
                show_buffer_icons = true,
                show_buffer_close_icons = false,
                show_buffer_default_icon = true,
                show_close_icon = false,
                show_tab_indicators = true,
                show_duplicate_prefix = true,
                enforce_regular_tabs = true,
                always_show_bufferline = true,
                persist_buffer_sort = true,
                -- sort_by = "id", -- 'relative_directory'
                sort_by = "insert_after_current",
                groups = {
                    options = {
                        toggle_hidden_on_enter = true
                    },
                    items = {
                        groups.builtin.pinned:with({icon = ""}),
                        groups.builtin.ungrouped,
                        {
                            name = "Dependencies",
                            icon = "",
                            highlight = {fg = require("kimbox.colors").yellow},
                            matcher = function(buf)
                                return vim.startswith(
                                    buf.path,
                                    ("%s/site/pack/packer"):format(dirs.data)
                                ) or vim.startswith(buf.path, fn.expand("$VIMRUNTIME"))
                            end
                        },
                        {
                            name = "Bufferize",
                            icon = "",
                            matcher = function(buf)
                                local match = buf.path:match("(Bufferize).*")
                                -- p(('hi: %s'):format(match))
                                return match
                            end
                        },
                        {
                            name = "SQL",
                            matcher = function(buf)
                                return buf.filename:match("%.sql$")
                            end
                        },
                        {
                            name = "tests",
                            icon = "",
                            highlight = {fg = "#418292", underline = true},
                            matcher = function(buf)
                                local name = buf.filename
                                if name:match("%.sql$") == nil then
                                    return false
                                end
                                return name:match("_spec") or name:match("_test")
                            end
                        },
                        {
                            name = "docs",
                            icon = "",
                            matcher = function(buf)
                                for _, ext in ipairs({"md", "txt", "org", "norg", "wiki"}) do
                                    if ext == fn.fnamemodify(buf.path, ":e") then
                                        return true
                                    end
                                end
                            end
                        }
                    }
                }
            },
            highlights = require("kimbox.bufferline").theme()
        }
    )
end

function M.setup_close_buffers()
    local close = D.npcall(require, "close_buffers")
    if not close then
        return
    end

    close.setup(
        {
            filetype_ignore = {}, -- Filetype to ignore when running deletions
            file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
            file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
            preserve_window_layout = {"this", "nameless"},
            next_buffer_cmd = function(windows)
                bufferline.cycle(-1)
                local bufnr = api.nvim_get_current_buf()

                for _, window in ipairs(windows) do
                    pcall(api.nvim_win_set_buf, window, bufnr)
                end
            end
        }
    )

    -- -- bdelete
    -- require('close_buffers').delete({ type = 'hidden', force = true }) -- Delete all non-visible buffers
    -- require('close_buffers').delete({ type = 'nameless' }) -- Delete all buffers without name
    -- require('close_buffers').delete({ type = 'this' }) -- Delete the current buffer
    -- require('close_buffers').delete({ type = 1 }) -- Delete the specified buffer number
    -- require('close_buffers').delete({ regex = '.*[.]md' }) -- Delete all buffers matching the regex
    --
    -- -- bwipeout
    -- require('close_buffers').wipe({ type = 'all', force = true }) -- Wipe all buffers
    -- require('close_buffers').wipe({ type = 'other' }) -- Wipe all buffers except the current focused
    -- require('close_buffers').wipe({ type = 'hidden', glob = '*.lua' }) -- Wipe all buffers matching the glob
end

local function init_hl()
    local normal_bg = hl.get("Normal", "bg")
    local bg_color = hl.alter_color(normal_bg, -8)

    hl.all(
        {
            PanelHeading = {background = bg_color, bold = true}
        }
    )
end

local function init()
    local wk = require("which-key")

    init_hl()

    M.setup()
    M.setup_close_buffers()

    wk.register(
        {
            ["[b"] = {"<cmd>BufferLineCyclePrev<CR>", "Previous buffer"},
            ["]b"] = {"<cmd>BufferLineCycleNext<CR>", "Next buffer"},
            ["<C-S-Left>"] = {"<cmd>BufferLineCyclePrev<CR>", "Previous buffer"},
            ["<C-S-Right>"] = {"<cmd>BufferLineCycleNext<CR>", "Next buffer"},
            ["<Leader>bu"] = {"<cmd>BufferLinePick<CR>", "Pick a buffer"},
            ["<Leader>bp"] = {"<Cmd>BufferLinePickClose<CR>", "Pick buffer to delete"},
            ["<C-A-Left>"] = {"<cmd>BufferLineMovePrev<CR>", "Move buffer a slot left"},
            ["<C-A-Right>"] = {"<cmd>BufferLineMoveNext<CR>", "Move buffer a slot right"}
        }
    )

    -- Builtin
    wk.register(
        {
            ["<Leader>b"] = {
                n = {":enew<CR>", "New buffer"},
                -- q = { ":bp <Bar> bd #<CR>", "Close buffer" },
                -- a = { "<Cmd>%bd|e#|bd#<Cr>", "Delete all buffers" },
                -- q = {"<Cmd>lua require('plugs.bufferline').bufdelete()<CR>", "Close buffer"},
                -- w = {"<Cmd>BWipeout other<cr>", "Delete all buffers except this"},
                -- Q = {":bufdo bd! #<CR>", "Close all buffers (force)"}
                q = {
                    pithunk(require("close_buffers").delete, {type = "this"}),
                    "Delete this buffer"
                },
                w = {pithunk(require("close_buffers").wipe, {type = "other"}), "Delete all buffers except this"},
                Q = {pithunk(require("close_buffers").wipe, {type = "all"}), "Close all buffers"}
            }
        }
    )

    -- map("n", "[b", [[:execute(v:count1 . 'bprev')<CR>]])
    -- map("n", "]b", [[:execute(v:count1 . 'bnext')<CR>]])

    for i = 1, 9 do
        wk.register(
            {
                [("<Leader><Leader>%d"):format(i)] = {
                    ("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
                    "which_key_ignore"
                    -- ("Go to buffer %d"):format(i)
                }
            }
        )

        -- map("n", "<Leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", {silent = true})
    end
end

init()

return M
