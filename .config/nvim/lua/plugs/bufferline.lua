---@module 'plugs.bufferline'
local M = {}

local F = Rc.F
local bufferline = F.npcall(require, "bufferline")
if not bufferline then
    return
end
local close = F.npcall(require, "close_buffers")
if not close then
    return
end

local C = Rc.shared.C
local hl = Rc.shared.hl
local I = Rc.icons

local groups = require("bufferline.groups")

local fn = vim.fn
local api = vim.api

local diagnostics_signs = {
    error = I.lsp.sb.error,
    warning = I.lsp.sb.warn,
    hint = I.lsp.sb.hint,
    info = I.lsp.sb.info,
}

---Filter out filetypes you don't want to see
---@param bufnr integer
---@param buf_nums integer[]
---@return boolean
local function custom_filter(bufnr, buf_nums)
    local bo = vim.bo[bufnr]

    local logs = C.filter(buf_nums, function(b)
        return vim.bo[b].ft == "log"
    end)
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
    if Rc.blacklist.bufname:contains(fn.bufname(bufnr)) then
        return false
    end

    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
    -- return true
end

---Function to show diagnostics in the bufferline
---@param _count integer
---@param _level string
---@param diagnostics table<string, integer>
---@param _context string
---@return string
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

---@class BufferLineNameFmtBuf
---@field name string basename of the active file
---@field path string full path of the active file
---@field bufnr integer (buf only) number of the active buffer
---@field buffers integer[] (tabs only) numbers of the buffers in the tab
---@field tabnr integer (tabs only) "handle" of the tab, convert to its ordinal`api.nvim_tabpage_get_number(buf.tabnr)`

---Can be used to change the buffer's label in the bufferline.
---@param buf BufferLineNameFmtBuf contains a "name", "path" and "bufnr"
---@return string?
local function name_formatter(buf)
    -- Remove extension from markdown files for example
    if buf.name:match("%.md") then
        return fn.fnamemodify(buf.name, ":t:r")
    end
end

function M.setup()
    local conf = {
        options = {
            -- debug = {logging = true},
            -- navigation = {mode = "uncentered"},
            mode = "buffers",
            themable = true, -- whether or not bufferline highlights can be overridden externally
            numbers = function(opts)
                return ("%s"):format(opts.raise(opts.ordinal))
            end,
            close_command = function(bufnr)
                close.delete({type = bufnr})
            end, -- can be a string | function, see "Mouse actions"
            right_mouse_command = function(bufnr)
                close.delete({type = bufnr})
            end,
            left_mouse_command = "buffer %d",
            middle_mouse_command = nil,
            -- indicator = {style = "NONE"},
            indicator = {
                icon = "▎", -- this should be omitted if indicator style is not 'icon'
                style = "icon",
            },
            buffer_close_icon = "",
            modified_icon = "●",
            close_icon = "",
            left_trunc_marker = "",
            right_trunc_marker = "",
            separator_style = "slope", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
            max_name_length = 20,
            max_prefix_length = 15,    -- prefix used when a buffer is de-duplicated
            tab_size = 20,
            name_formatter = name_formatter,
            custom_filter = custom_filter,
            diagnostics = "coc", -- false
            diagnostics_indicator = diagnostics_indicator,
            diagnostics_update_in_insert = false,
            offsets = {
                {
                    text = "Undotree",
                    filetype = "undotree",
                    highlight = "Type",
                    separator = true,
                },
                {
                    text = "DiffView",
                    filetype = "DiffviewFiles",
                    highlight = "DiffAdd",
                    separator = true,
                },
                {
                    text = "Symbols",
                    filetype = "Outline",
                    highlight = "@bold",
                    separator = true,
                },
                {
                    text = " Packer",
                    filetype = "packer",
                    highlight = "Title",
                    separator = true,
                },
                {
                    text = "Aerial",
                    filetype = "aerial",
                    text_align = "center",
                    highlight = "Function",
                    separator = true,
                },
                {
                    text = "CocTree",
                    filetype = "coctree",
                    highlight = "@bold",
                    separator = true,
                },
                {
                    text = "Vista",
                    filetype = "vista",
                    highlight = "Statement",
                    separator = true,
                },
            },
            color_icons = true,
            show_buffer_icons = true,
            show_buffer_close_icons = false,
            show_close_icon = false,
            show_tab_indicators = true,
            show_duplicate_prefix = true,
            -- get_element_icon = function(buf)
            --     -- {filetype: string, path: string, extension: string, directory: string}
            --     local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(
            --         opts.filetype,
            --         {default = false}
            --     )
            --     return icon, hl
            --     -- or
            --     -- local custom_map = {my_thing_ft: {icon = "my_thing_icon", hl}}
            --     -- return custom_map[element.filetype]
            -- end,
            enforce_regular_tabs = false,
            always_show_bufferline = true,
            persist_buffer_sort = true,
            -- insert_after_current|insert_at_end|id|extension|relative_directory|directory|tabs
            sort_by = "insert_after_current",
            -- sort_by =  function(buffer_a, buffer_b)
            --     return buffer_a.modified > buffer_b.modified
            -- end,
            hover = {
                enabled = true,
                delay = 200,
                reveal = {"close"},
            },
            groups = {
                options = {
                    toggle_hidden_on_enter = true,
                },
                items = {
                    groups.builtin.pinned:with({icon = ""}),
                    groups.builtin.ungrouped,
                    -- {
                    --     name = "Dependencies",
                    --     icon = "",
                    --     highlight = {
                    --         fg = require("kimbox.colors").yellow,
                    --     },
                    --     matcher = function(buf)
                    --         return buf.path:startswith(vim.env.VIMRUNTIME)
                    --             or buf.path:startswith(("%s/site/pack/packer"):format(Rc.dirs.data))
                    --     end,
                    -- },
                    -- {
                    --     name = "Bufferize",
                    --     icon = "",
                    --     matcher = function(buf)
                    --         -- FIX: pattern with parens fails
                    --         --   name = "Bufferize: lua p(fn.api_info())",
                    --         --   name = "Bufferize: lua p 'hi'",
                    --
                    --         -- return buf.name:match("Bufferize")
                    --
                    --         -- local fend = fn.fnamemodify(buf.path, ":t")
                    --         -- local sp = fend:split()[1]
                    --         -- return fend:match("Bufferize")
                    --
                    --         -- return sp == "Bufferize:"
                    --
                    --         -- local name = buf.name:split(":")[1]
                    --         -- local match = name:match("Bufferize$")
                    --         -- if match then
                    --         --     N(match)
                    --         --     return true
                    --         -- end
                    --         -- return false
                    --     end,
                    -- },
                    {
                        name = "SQL",
                        matcher = function(buf)
                            return buf.name:match("%.sql$")
                        end,
                    },
                    {
                        name = "tests",
                        icon = "",
                        highlight = {
                            fg = "#418292",
                            underline = true,
                        },
                        matcher = function(buf)
                            local name = buf.name
                            return name:match("[_%.]spec") or name:match("[_%.]test")
                        end,
                    },
                    {
                        name = "docs",
                        icon = "",
                        matcher = function(buf)
                            if vim.bo[buf.id].ft == "man" or buf.path:match("man://") then
                                return true
                            end
                            for _, ext in ipairs({"md", "txt", "org", "norg", "wiki"}) do
                                if ext == fn.fnamemodify(buf.path, ":e") then
                                    return true
                                end
                            end
                        end,
                    },
                },
            },
        },
    }

    if vim.g.colors_name == "kimbox" then
        conf.highlights = require("kimbox.bufferline").theme()
    end

    bufferline.setup(conf)
end

---Setup `close-buffers.nvim`
function M.setup_close_buffers()
    close.setup({
        filetype_ignore = {},       -- Filetype to ignore when running deletions
        file_glob_ignore = {},      -- File name glob pattern to ignore when running deletions (e.g. '*.md')
        file_regex_ignore = {},     -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
        preserve_window_layout = {"this", "nameless"},
        next_buffer_cmd = function(windows)
            bufferline.cycle(-1)
            local bufnr = api.nvim_get_current_buf()

            for _, window in ipairs(windows) do
                pcall(api.nvim_win_set_buf, window, bufnr)
            end
        end,
    })
    -- bdelete
    -- .delete({ type = 'hidden', force = true }) -- Delete all non-visible buffers
    -- .delete({ type = 'nameless' })             -- Delete all buffers without name
    -- .delete({ type = 'this' })                 -- Delete the current buffer
    -- .delete({ type = 1 })                      -- Delete the specified buffer number
    -- .delete({ regex = '.*[.]md' })             -- Delete all buffers matching the regex
    --
    -- bwipeout
    -- .wipe({ type = 'all', force = true })      -- Wipe all buffers
    -- .wipe({ type = 'other' })                  -- Wipe all buffers except the current focused
    -- .wipe({ type = 'hidden', glob = '*.lua' }) -- Wipe all buffers matching the glob
end

local function init_hl()
    local normal_bg = hl.get("Normal", "bg")
    local bg_color = hl.alter_color(normal_bg, -8)

    hl.all({
        PanelHeading = {
            bg = bg_color,
            bold = true,
        },
    })
end

local function init()
    local wk = require("which-key")

    init_hl()

    M.setup()
    M.setup_close_buffers()

    wk.register({
        -- ["[b"] = {"<cmd>BufferLineCyclePrev<CR>", "Previous buffer"},
        -- ["]b"] = {"<cmd>BufferLineCycleNext<CR>", "Next buffer"},
        ["<C-S-Left>"] = {"<cmd>BufferLineCyclePrev<CR>", "Previous buffer"},
        ["<C-S-Right>"] = {"<cmd>BufferLineCycleNext<CR>", "Next buffer"},
        ["<Leader>bu"] = {"<cmd>BufferLinePick<CR>", "Pick a buffer"},
        ["<Leader>bp"] = {"<Cmd>BufferLinePickClose<CR>", "Pick buffer to delete"},
        ["<M-S-Left>"] = {"<cmd>BufferLineMovePrev<CR>", "Move buffer a slot left"},
        ["<M-S-Right>"] = {"<cmd>BufferLineMoveNext<CR>", "Move buffer a slot right"},
    })

    wk.register({
        ["<Leader>b"] = {
            n = {"<Cmd>enew<CR>", "New buffer"},
            -- q = {":bp <Bar> bd #<CR>", "Close buffer"},
            -- a = { "<Cmd>%bd|e#|bd#<Cr>", "Delete all buffers" },
            -- q = {"<Cmd>lua require('plugs.bufferline').bufdelete()<CR>", "Close buffer"},
            -- w = {"<Cmd>BWipeout other<cr>", "Delete all buffers except this"},
            -- Q = {":bufdo bd! #<CR>", "Close all buffers (force)"}
            q = {F.pithunk(close.delete, {type = "this"}), "Delete this buffer"},
            w = {F.pithunk(close.wipe, {type = "other"}), "Delete all buffers except this"},
            Q = {F.pithunk(close.wipe, {type = "all"}), "Close all buffers"},
        },
    })

    for i = 1, 9 do
        wk.register({
            [("<Leader><Leader>%d"):format(i)] = {
                ("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
                "which_key_ignore",
                -- ("Go to buffer %d"):format(i)
            },
        })

        -- map("n", "<Leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", {silent = true})
    end
end

init()

return M
