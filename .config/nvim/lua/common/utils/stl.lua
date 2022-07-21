---@diagnostic disable:need-check-nil
---@diagnostic disable:undefined-field

local M = {}

M.plugins = {}
M.extensions = {}
M.conditions = {}
M.other = {}

local utils = require("common.utils")
local gittool = require("common.gittool")
local devicons = require("nvim-web-devicons")
local dev = require("dev")
local coc = require("plugs.coc")
local C = require("common.color")
local colors = require("kimbox.colors")
local icons = require("style").icons

local api = vim.api
local fn = vim.fn
local g = vim.g

-- TODO: Create a statusline changelist showing current change/total
-- TODO: Create a statusline jumplist showing current jump/total

-- ╒══════════════════════════════════════════════════════════╕
--                            Other
-- ╘══════════════════════════════════════════════════════════╛
M.other.only_pad_right = {left = 1, right = 0}

-- ╒══════════════════════════════════════════════════════════╕
--                          Conditions
-- ╘══════════════════════════════════════════════════════════╛
M.conditions = {
    -- Show function in statusbar
    is_available_gps = function()
        if require("nvim-gps") then
            return require("nvim-gps").is_available()
        end
        return false
    end,
    hide_in_width = function()
        return fn.winwidth(0) > 80
    end,
    coc_status_width = function()
        if fn.exists("g:coc_status") and g.coc_status then
            if #g.coc_status > 28 then
                return false
            end
        end
        return true
    end,
    buffer_not_empty = function()
        return fn.empty(fn.expand("%:t")) ~= 1
    end,
    has_file_type = function()
        return vim.bo.ft or not vim.bo.ft == ""
    end,
    is_lsp_attached = function()
        return not vim.tbl_isempty(vim.lsp.buf_get_clients())
    end,
    check_git_workspace = function()
        -- local filepath = fn.expand("%:p:h")
        -- local gitdir = fn.finddir(".git", filepath .. ";")
        -- return gitdir and #gitdir > 0 and #gitdir < #filepath
        return #gittool.root() > 0
    end
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Plugins
-- ╘══════════════════════════════════════════════════════════╛

M.plugins.sep = function()
    return ""
end

local get_lsp_client = function()
    local msg = "LSP Inactive"
    local buf_ft = vim.bo.filetype
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
        return msg
    end
    local lsps = ""
    for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and fn.index(filetypes, buf_ft) ~= -1 then
            if lsps == "" then
                lsps = client.name
            else
                if not string.find(lsps, client.name) then
                    lsps = lsps .. ", " .. client.name
                end
            end
        end
    end
    if lsps == "" then
        return msg
    else
        return lsps
    end
end

---Get the LSP's status
---@return string
M.plugins.lsp_status = {
    fn = function()
        local progress_message = vim.lsp.util.get_progress_messages()
        if #progress_message == 0 then
            return get_lsp_client()
        end

        local status = {}
        for _, msg in pairs(progress_message) do
            table.insert(status, (msg.percentage or 0) .. "%% " .. (msg.title or ""))
        end
        return table.concat(status, " ")
    end
}

---Get the LSP's status using lsp-status
---@return string
M.plugins.lsp_status2 = {
    fn = function()
        local spinner_frames = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"}
        local success, lsp_status = pcall(require, "lsp-status")
        if not success then
            return ""
        end
        local buf_messages = lsp_status.messages()
        if vim.tbl_isempty(buf_messages) then
            return ""
        end
        local msgs = {}
        for _, msg in ipairs(buf_messages) do
            local name = msg.name
            local client_name = name
            local contents = ""
            if msg.progress then
                contents = msg.title
                if msg.message then
                    contents = contents .. " " .. msg.message
                end

                if msg.percentage then
                    contents = contents .. "(" .. msg.percentage .. ")"
                end

                if msg.spinner then
                    contents = contents .. " " .. spinner_frames[(msg.spinner % #spinner_frames) + 1]
                end
            elseif msg.status then
                contents = msg.content
                if msg.uri then
                    local filename = vim.uri_to_fname(msg.uri)
                    filename = fn.fnamemodify(filename, ":~:.")
                    local space = math.min(60, math.floor(0.6 * vim.opt.columns:get()))
                    if #filename > space then
                        filename = fn.pathshorten(filename)
                    end

                    contents = "(" .. filename .. ") " .. contents
                end
            else
                contents = msg.content
            end

            table.insert(msgs, client_name .. ":" .. contents)
        end
        status = ""
        for index, msg in ipairs(msgs) do
            status = status .. (index > 1 and " | " or "") .. msg
        end
        return status .. " "
    end
}

M.plugins.blame = {
    fn = function()
        if vim.b.gitsigns_blame_line_dict then
            local info = vim.b.gitsigns_blame_line_dict
            local date_time = require("gitsigns.util").get_relative_time(tonumber(info.author_time))
            return ("%s - %s"):format(info.author, date_time)
        end
        return ""
    end
}

M.plugins.recording = {
    fn = function()
        local reg = fn.reg_recording()
        if reg ~= "" then
            return ("Recording[%s]"):format(reg)
        else
            return ""
        end
    end
}

M.plugins.gitbuf = {
    fn = function()
        local name = api.nvim_eval_statusline("%f", {}).str
        if vim.startswith(name, "fugitive://") then
            ---@diagnostic disable-next-line:unused-local
            local _, _, commit, relpath = name:find([[^fugitive://.*/%.git.*/(%x-)/(.*)]])
            return ("fugitive@%s"):format(commit:sub(1, 7))
            -- name = relpath .. "@" .. commit:sub(1, 7)
        end
        if vim.startswith(name, "gitsigns://") then
            ---@diagnostic disable-next-line:unused-local
            local _, _, revision, relpath = name:find([[^gitsigns://.*/%.git.*/(.*):(.*)]])
            return ("gitsigns@%s"):format(revision:sub(1, 7))
            -- name = relpath .. "@" .. revision:sub(1, 7)
        end
        return ""
    end
}

M.plugins.coc_status = {
    fn = function()
        return vim.trim(g.coc_status or "")
    end
}

---Display an icon if spelling is on
M.plugins.spell = {
    toggle = function()
        return api.nvim_win_get_option(0, "spell")
    end,
    fn = ([[%%"%s]]):format(icons.misc.spell)
}

M.plugins.wrap = {
    toggle = function()
        return api.nvim_win_get_option(0, "wrap")
    end,
    fn = [[%"w]]
}

---Show space information about the buffer
M.plugins.space_info = function()
    return "%{&expandtab?'Spc:'.&shiftwidth:'Tab:'.&shiftwidth}"
end

-- FIX: Runs way to often
---Show number of TODO comments in buffer
M.plugins.todo_comment_count = {
    toggle = function()
        return dev.plugin_loaded("todo-comments.nvim")
    end,
    fn = function()
        return require("plugs.todo-comments").get_todo_count()
    end
}

---Show function is statusbar with vista
M.plugins.vista_nearest_method = {
    toggle = function()
        return dev.plugin_loaded("vista.vim")
    end,
    fn = function()
        return vim.b.vista_nearest_method_or_function
    end
}

M.plugins.coc_function = {
    toggle = function()
        return g.coc_current_function ~= nil
    end,
    fn = function()
        return g.coc_current_function
    end
}

M.plugins.gutentags_progress = {
    toggle = function()
        return dev.plugin_loaded("vim-gutentags")
    end,
    fn = function()
        return fn["gutentags#statusline"]("[", "]")
    end
}

M.plugins.gps = {
    toggle = function()
        return dev.plugin_loaded("nvim-gps")
    end,
    fn = function()
        local opts = {
            disable_icons = false,
            separator = " > ",
            depth = 4,
            dept_limit_indicator = ".."
        }
        return require("nvim-gps").get_location(opts)
    end
}

M.plugins.luapad = {
    toggle = function()
        return dev.plugin_loaded("nvim-luapad")
    end,
    fn = function()
        local status = fn["luapad#lightline_status"]()
        local msg = fn["luapad#lightline_msg"]

        if status == "OK" then
            return ("%s - %s"):format(status, msg)
        end

        return ""
    end
}

M.plugins.debugger = {
    toggle = function()
        return dev.plugin_loaded("dap")
    end,
    fn = function()
        -- local session = require('dap').session()
        -- return session ~= nil and session.config ~= nil and session.config.type or ''

        local ok, dap = pcall(require, "dap")
        return ok and dap.status()
    end
}

M.plugins.file_encoding = {
    toggle = function()
        local encoding = vim.opt.fileencoding:get()
        return encoding ~= "utf-8"
    end,
    fn = function()
        return vim.opt.fileencoding:get()
    end
}

M.plugins.search_result = {
    fn = function()
        if vim.v.hlsearch == 0 then
            return ""
        end
        local last_search = nvim.reg["/"]
        if not last_search or last_search == "" then
            return ""
        end

        -- If the user searches for ',\)', and 'unmatched' error occurs
        local searchcount = fn.searchcount({maxcount = 9999})
        if vim.tbl_isempty(searchcount) then
            return ""
        end

        return last_search .. "[" .. searchcount.current .. "/" .. searchcount.total .. "]"
    end
}

---Alternate progress indicator
M.plugins.progress = {
    fn = function()
        local current_line = fn.line(".")
        local total_lines = fn.line("$")
        local chars = {
            "__",
            "▁▁",
            "▂▂",
            "▃▃",
            "▄▄",
            "▅▅",
            "▆▆",
            "▇▇",
            "██"
        }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)
        return chars[index]
    end
}

---arsham/arshamiser
---Show number of items in locationlist
M.plugins.loclist_count = {
    fn = function()
        local ll = fn.getloclist(fn.winnr(), {idx = 0, size = 0})
        local count = ll.size
        local current = ll.idx
        return count == 0 and "" or ("%s %d/%d "):format(icons.misc.loclist, current, count)
    end
}

---arsham/arshamiser
---Show number of items in quickfix
M.plugins.quickfix_count = {
    fn = function()
        local qf = fn.getqflist({idx = 0, size = 0})
        local count = qf.size
        local current = qf.idx
        return count == 0 and "" or ("%s %d/%d "):format(icons.misc.quickfix, current, count)
    end
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Terminal
-- ╘══════════════════════════════════════════════════════════╛
local function terminal_status_color(status)
    local mode_colors = {
        Running = colors.orange,
        Finished = colors.purple,
        Success = colors.blue,
        Error = colors.red,
        Command = colors.magenta
    }

    return mode_colors[status]
end

local function get_exit_status()
    local ln = api.nvim_buf_line_count(0)
    while ln >= 1 do
        local l = api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
        ln = ln - 1
        local exit_code = string.match(l, "^%[Process exited ([0-9]+)%]$")
        if exit_code ~= nil then
            return tonumber(exit_code)
        end
    end
end

local function terminal_status()
    -- vim.trim(ex.filter(("/%s/ ls! uaF"):format(fn.escape(api.nvim_buf_get_name(api.nvim_get_current_buf()), "~/"))))
    if
        api.nvim_exec([[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaF"))]], true) ~=
            ""
     then
        local result = get_exit_status()
        if result == nil then
            return "Finished"
        elseif result == 0 then
            return "Success"
        elseif result >= 1 then
            return "Error"
        end
        return "Finished"
    end
    if
        api.nvim_exec([[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaR"))]], true) ~=
            ""
     then
        return "Running"
    end
    return "Command"
end

local function get_terminal_status()
    if vim.bo.buftype ~= "terminal" then
        return ""
    end
    local status = terminal_status()
    C.set_hl("LualineToggleTermStatus", {fg = terminal_status_color(status), bg = colors.bg0, bold = true})
    return status
end

local function toggleterm_statusline()
    local icon = devicons.get_icon_by_filetype("terminal")
    return ("%s ToggleTerm #%d"):format(icon, vim.b.toggle_number)
end

-- local function term_title()
--     local title = vim.b.term_title
--     title = title:gsub("%d+:[^%s]+%s.*", "")
--     return title
-- end

M.extensions.toggleterm = {
    sections = {
        lualine_a = {toggleterm_statusline},
        -- lualine_b = {{term_title, color = {fg = colors.green}}},
        lualine_z = {{get_terminal_status, color = "LualineToggleTermStatus"}}
    },
    filetypes = {"toggleterm"}
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Quickfix
-- ╘══════════════════════════════════════════════════════════╛
local function is_loclist()
    local winid = api.nvim_get_current_win()
    return fn.getwininfo(winid)[1].loclist == 1
    -- return fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0
end

local function qf_title()
    return is_loclist() and "Location" or "Quickfix"
end

local function qf_cmd()
    local winid = api.nvim_get_current_win()
    return vim.w[winid].quickfix_title or ""
end

local function quickfix()
    local what = {nr = 0, size = 0}
    local info = is_loclist() and fn.getloclist(0, what) or fn.getqflist(what)
    what = {nr = "$"}
    local nr = (is_loclist() and fn.getloclist(0, what) or fn.getqflist(what)).nr

    return ("(%d/%d)"):format(info.nr, nr)
end

M.extensions.qf = {
    sections = {
        -- lualine_a = {quickfix},
        lualine_a = {qf_title},
        lualine_b = {
            {
                quickfix,
                color = {fg = colors.green}
            },
            {
                "%p%% [%L]",
                color = {fg = colors.orange, gui = "bold"}
            }
        },
        lualine_c = {
            {qf_cmd, color = {fg = colors.yellow}}
        }
    },
    filetypes = {"qf"}
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Trouble
-- ╘══════════════════════════════════════════════════════════╛

function M.document_diagnostics()
    local diagnostics = {}
    -- Maybe a better way to get previous buffer
    -- Would also be nice to distinguish between workspace and document
    local bufnr = fn.bufnr("#")

    if not coc.did_init() then
        return diagnostics
    end

    -- Use a default {} to prevent indexing errors
    local data = vim.b[bufnr].coc_diagnostic_info or {}
    return {
        error = utils.get_default(data.error, 0),
        warn = utils.get_default(data.warning, 0),
        info = utils.get_default(data.information, 0),
        hint = utils.get_default(data.hint, 0)
    }

    -- fn.CocActionAsync(
    --     "diagnosticList",
    --     function(err, res)
    --         if err ~= vim.NIL then
    --             return
    --         end
    --
    --         res = type(res) == "table" and res or {}
    --         local result = {}
    --         local bufname2bufnr = {}
    --         for _, diagnostic in ipairs(res) do
    --             local bufname = diagnostic.file
    --             local bufnr = bufname2bufnr[bufname]
    --             if not bufnr then
    --                 bufnr = fn.bufnr(bufname)
    --                 bufname2bufnr[bufname] = bufnr
    --             end
    --             if bufnr ~= -1 then
    --                 result[bufnr] = result[bufnr] or {}
    --                 table.insert(result[bufnr], {severity = diagnostic.level})
    --             end
    --         end
    --         diagnostics = result
    --     end
    -- )
    --
    -- return diagnostics
end

M.extensions.trouble = {
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = function(str)
                    return ("%s %s"):format(str, "")
                end,
                padding = M.other.only_pad_right
            }
        },
        lualine_b = {
            {
                "filetype",
                fmt = function(str)
                    return ("[%s] %s"):format(icons.misc.list, str)
                end,
                color = {fg = colors.red, gui = "bold"}
            }
        },
        lualine_c = {
            {
                "diagnostics",
                sources = {M.document_diagnostics},
                symbols = {
                    error = icons.lsp.sb.error,
                    warn = icons.lsp.sb.warn,
                    info = icons.lsp.sb.info,
                    hint = icons.lsp.sb.hint
                }
            }
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
            "%l:%c",
            "%p%%/%L"
        }
    },
    filetypes = {"Trouble"}
}

return M
