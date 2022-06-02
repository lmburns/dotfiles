local M = {}

-- local utils = require("common.utils")
-- local map = utils.map

local color = require("common.color")
local groups = require("bufferline.groups")

local ex = nvim.ex
local api = vim.api
local fn = vim.fn

local diagnostics_signs = {
    error = "",
    warning = "",
    hint = "",
    info = ""
}

---Filter out filetypes you don't want to see
local function custom_filter(bufnr, buf_nums)
    local bo = vim.bo[bufnr]

    local logs =
        vim.tbl_filter(
        function(b)
            return vim.bo[b].ft == "log"
        end,
        buf_nums
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

    -- -- filter out based on arbitrary rules
    -- -- e.g. filter out vim wiki buffer from tabline in your work repo
    -- if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
    --   return true
    -- end

    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
    -- return true
end

---Function to show diagnostics in the bufferline
local function diagnostics_indicator(_count, _level, diagnostics, _context)
    local result = {}
    for name, count in pairs(diagnostics) do
        if diagnostics_signs[name] and count > 0 then
            table.insert(result, ("%s %d"):format(diagnostics_signs[name], count))
        end
    end
    result = table.concat(result, " ")
    return #result > 0 and result or ""
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
    require("bufferline").setup(
        {
            options = {
                mode = "buffers",
                numbers = function(opts)
                    return ("%s"):format(opts.raise(opts.ordinal))
                end,
                close_command = "Bdelete %d", -- can be a string | function, see "Mouse actions"
                right_mouse_command = "Bdelete %d", -- can be a string | function, see "Mouse actions"
                left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
                middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
                indicator_icon = "▎",
                buffer_close_icon = "",
                modified_icon = "●",
                close_icon = "",
                left_trunc_marker = "",
                right_trunc_marker = "",
                max_name_length = 20,
                max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
                tab_size = 20,
                name_formatter = name_formatter,
                diagnostics = "coc", -- false
                diagnostics_indicator = diagnostics_indicator,
                diagnostics_update_in_insert = false,
                custom_filter = custom_filter,
                -- offsets = {
                --   {filetype = "NvimTree", text = "File Explorer", text_align = "left" | "center" | "right"}
                -- },
                offsets = {
                    {
                        filetype = "undotree",
                        text = "Undotree",
                        highlight = "PanelHeading"
                    },
                    {
                        filetype = "DiffviewFiles",
                        text = "Diff View",
                        highlight = "PanelHeading"
                    },
                    {
                        filetype = "Outline",
                        text = "Symbols",
                        highlight = "PanelHeading"
                    },
                    {
                        filetype = "packer",
                        text = "Packer",
                        highlight = "PanelHeading"
                    }
                },
                show_buffer_icons = true,
                show_buffer_close_icons = false,
                show_close_icon = false,
                show_tab_indicators = true,
                -- persist_buffer_sort = true, -- whether or not custom sorted buffers should persist

                -- can also be a table containing 2 custom separators
                -- [focused and unfocused]. eg: { '|', '|' }
                separator_style = "slant",
                enforce_regular_tabs = true,
                groups = {
                    options = {
                        toggle_hidden_on_enter = true
                    },
                    items = {
                        groups.builtin.ungrouped,
                        {
                            name = "Terraform",
                            matcher = function(buf)
                                return buf.name:match("%.tf") ~= nil
                            end
                        },
                        {
                            highlight = {guisp = "#51AFEF", gui = "underline"},
                            name = "tests",
                            icon = "",
                            matcher = function(buf)
                                return buf.filename:match("_spec") or buf.filename:match("_test")
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

                -- always_show_bufferline = true
                -- sort_by = 'relative_directory'
            },
            highlights = require("kimbox.bufferline").theme()
        }
    )
end

---Bufdelete moves forward, I'm used to moving backwards
function M.bufdelete()
    local bufnr = api.nvim_get_current_buf()
    ex.bp()
    require("bufdelete").bufdelete(bufnr)
end

local function init_hl()
    local normal_bg = color.get_hl("Normal", "bg")
    local bg_color = color.alter_color(normal_bg, -8)

    color.all(
        {
            PanelHeading = {background = bg_color, bold = true}
        }
    )
end

local function init()
    local wk = require("which-key")

    init_hl()

    wk.register(
        {
            ["[b"] = {"<cmd>BufferLineCyclePrev<CR>", "Previous buffer"},
            ["]b"] = {"<cmd>BufferLineCycleNext<CR>", "Next buffer"},
            ["<C-S-Left>"] = {"<cmd>BufferLineCyclePrev<CR>", "Previous buffer"},
            ["<C-S-Right>"] = {"<cmd>BufferLineCycleNext<CR>", "Next buffer"},
            ["<Leader>bu"] = {"<cmd>BufferLinePick<CR>", "Pick a buffer"},
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
                q = {"<Cmd>lua require('plugs.bufferline').bufdelete()<CR>", "Close buffer"},
                Q = {":bufdo bd! #<CR>", "Close all buffers"}
            }
        }
    )

    -- map("n", "[b", [[:execute(v:count1 . 'bprev')<CR>]])
    -- map("n", "]b", [[:execute(v:count1 . 'bnext')<CR>]])

    for i = 1, 9 do
        i = tostring(i)
        wk.register(
            {
                [("<Leader>%d"):format(i)] = {
                    ("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
                    ("Go to buffer %d"):format(i)
                }
            }
        )

        -- map("n", "<Leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", {silent = true})
    end

    M.setup()
end

init()

return M
