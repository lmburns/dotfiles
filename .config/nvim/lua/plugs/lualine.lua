local M = {}

local C = require("common.color")
local colors = require("kimbox.colors")
local style = require("style")
local icons = style.icons

local utils = require("common.utils")
local map = utils.map

local fn = vim.fn
local api = vim.api
local g = vim.g

-- ╒══════════════════════════════════════════════════════════╕
--                          Conditions
-- ╘══════════════════════════════════════════════════════════╛
local conditions = {
    -- Show function in statusbar
    is_available_gps = function()
        if require("nvim-gps") then
            return require("nvim-gps").is_available()
        end
        return false
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
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
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Plugins
-- ╘══════════════════════════════════════════════════════════╛
local plugins = {
    -- FIX: Runs way to often
    -- Show number of TODO comments in buffer
    todo_comment_count = function()
        if not nvim.plugins["todo-comments.nvim"].loaded then
            return ""
        end
        return require("plugs.todo-comments").get_todo_count()
    end,
    -- Show function is statusbar with vista
    vista_nearest_method = function()
        if not nvim.plugins["vista.vim"].loaded then
            return ""
        end
        return vim.b.vista_nearest_method_or_function
    end,
    gutentags_progress = function()
        if not nvim.plugins["vim-gutentags"].loaded then
            return ""
        end
        return fn["gutentags#statusline"]("[", "]")
    end,
    gps = function()
        if not nvim.plugins["nvim-gps"].loaded then
            return ""
        end
        local opts = {
            disable_icons = false,
            separator = " > ",
            depth = 4,
            dept_limit_indicator = ".."
        }
        return require("nvim-gps").get_location(opts)
    end,
    luapad = function()
        if not nvim.plugins["nvim-luapad"].loaded then
            return ""
        end

        local status = fn["luapad#lightline_status"]()
        local msg = fn["luapad#lightline_msg"]

        if status == "OK" then
            return ("%s - %s"):format(status, msg)
        else
            return ""
        end
    end,
    debugger = function()
        if not nvim.plugins["dap"].loaded then
            return ""
        end
        -- local session = require('dap').session()
        -- return session ~= nil and session.config ~= nil and session.config.type or ''
        return require("dap").status()
    end,
    file_encoding = function()
        local encoding = vim.opt.fileencoding:get()
        if encoding == "utf-8" then
            return ""
        else
            return encoding
        end
    end,
    search_result = function()
        if vim.v.hlsearch == 0 then
            return ""
        end
        local last_search = fn.getreg("/")
        if not last_search or last_search == "" then
            return ""
        end
        local searchcount = fn.searchcount {maxcount = 9999}
        return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
    end,
    progress = function()
        local current_line = vim.fn.line "."
        local total_lines = vim.fn.line "$"
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
    end,
    coc_status = function()
        return vim.trim(g.coc_status or "")
    end,
    lsp_status = function()
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
                    filename = vim.fn.fnamemodify(filename, ":~:.")
                    local space = math.min(60, math.floor(0.6 * vim.opt.columns:get()))
                    if #filename > space then
                        filename = vim.fn.pathshorten(filename)
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
    end,
    sep = function()
        return ""
    end,
    -- arsham/arshamiser
    loclist_count = function()
        local ll = fn.getloclist(fn.winnr(), {idx = 0, size = 0})
        local count = ll.size
        local current = ll.idx
        return count == 0 and "" or ("%s %d/%d "):format(icons.misc.loclist, current, count)
    end,
    quickfix_count = function()
        local qf = fn.getqflist({idx = 0, size = 0})
        local count = qf.size
        local current = qf.idx
        return count == 0 and "" or ("%s %d/%d "):format(icons.misc.quickfix, current, count)
    end
}

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 1
-- ╘══════════════════════════════════════════════════════════╛
local sections_1 = {
    lualine_a = {
        {
            -- Doesn't show operator mode?
            "mode",
            fmt = function(str)
                return str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1))
            end
        }
    },
    lualine_b = {
        {"filetype", icon_only = false},
        {
            "filesize",
            cond = conditions.hide_in_width,
            color = {fg = colors.green}
        },
        plugins.file_encoding,
        {
            "filename",
            path = 0,
            symbols = {
                modified = icons.misc.modified,
                readonly = icons.misc.readonly,
                unnamed = icons.misc.unnamed,
                shorting_target = 40
            },
            color = function(section)
                -- return { fg = vim.bo.modified and colors.purple or colors.fg }
                return {gui = vim.bo.modified and "bold" or "none"}
            end
        },
        {
            "%w",
            cond = function()
                return vim.wo.previewwindow
            end
        }
    },
    lualine_c = {plugins.coc_status},
    lualine_x = {},
    lualine_y = {
        {
            plugins.gps,
            cond = function()
                return conditions.is_available_gps() and conditions.hide_in_width() and conditions.coc_status_width()
            end,
            color = {fg = colors.red}
        },
        {
            "diagnostics",
            sources = {"nvim_diagnostic", "coc"},
            symbols = {
                error = icons.lsp.sb.error,
                warn = icons.lsp.sb.warn,
                info = icons.lsp.sb.info,
                hint = icons.lsp.sb.hint
            }
        },
        {
            "diff",
            -- diff_color = {
            --     added = "DiffAdd",
            --     modified = "DiffChange",
            --     removed = "DiffDelete"
            -- },
            symbols = {added = icons.git.add, modified = icons.git.mod, removed = icons.git.remove}
        },
        plugins.luapad,
        plugins.debugger
    },
    lualine_z = {
        {
            "branch",
            icon = icons.git.branch,
            cond = function()
                return conditions.check_git_workspace() and plugins.search_result() == ""
            end
        },
        plugins.quickfix_count,
        plugins.loclist_count,
        "%l:%c",
        -- "%p%%" .. (("/%s"):format(require("common.builtin").tokei() or "")) .. "/%L",
        "%p%%/%L",
        plugins.search_result
    }
}

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 2
-- ╘══════════════════════════════════════════════════════════╛
local sections_2 = {
    lualine_a = {"mode"},
    lualine_b = {
        {"filetype", icon_only = true},
        "fileformat",
        {"filesize", cond = conditions.hide_in_width},
        plugins.file_encoding,
        {
            "filename",
            path = 1,
            symbols = {modified = icons.misc.modified, readonly = icons.misc.readonly, unnamed = icons.misc.unnamed}
        }
    },
    lualine_c = {},
    lualine_x = {
        {
            -- "aerial"
            'require("nvim-gps").get_location()',
            cond = conditions.is_available_gps,
            color = {fg = colors.red}
        },
        {"branch", icon = icons.git.branch, cond = conditions.check_git_workspace}
        -- "b:gitsigns_head"
        -- "Fugitivehead"
    },
    lualine_y = {plugins.progress, plugins.gutentags_progress},
    lualine_z = {"location"}
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Mapping
-- ╘══════════════════════════════════════════════════════════╛
function M.toggle_mode()
    local ll_req = require("lualine_require")
    local modules = ll_req.lazy_require({config_module = "lualine.config"})
    local lutils = require("lualine.utils.utils")

    local current_config = modules.config_module.get_config()
    if vim.inspect(current_config.sections) == vim.inspect(sections_1) then
        current_config.sections = lutils.deepcopy(sections_2)
    else
        current_config.sections = lutils.deepcopy(sections_1)
    end
    require("lualine").setup(current_config)
end

map("n", "!", ":lua require('plugs.lualine').toggle_mode()<CR>", {silent = true})

-- ╒══════════════════════════════════════════════════════════╕
--                           Terminal
-- ╘══════════════════════════════════════════════════════════╛
local terminal_status_color = function(status)
    local mode_colors = {
        Running = colors.orange,
        Finished = colors.purple,
        Success = colors.blue,
        Error = colors.red,
        Command = colors.magenta
    }

    return mode_colors[status]
end

local get_exit_status = function()
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

local terminal_status = function()
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
    return "ToggleTerm #" .. vim.b.toggle_number
end

local function term_title()
    local title = vim.b.term_title
    title = title:gsub("%d+:[^%s]+%s.*", "")
    return title
end

local my_toggleterm = {
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
    -- return vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0
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

local my_qf = {
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
--                             Init
-- ╘══════════════════════════════════════════════════════════╛
local function init()
    local my_extension = {
        sections = {
            lualine_a = {"mode"},
            lualine_b = {"filetype"},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {
                "%l:%c",
                "%p%%/%L"
            }
        },
        filetypes = {
            "packer",
            "vista",
            "NvimTree",
            "coc-explorer",
            "coctree",
            "NeogitStatus",
            "Trouble",
            "TelescopePrompt",
            "tsplayground",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches"
        } -- aerial
    }

    require("lualine").setup(
        {
            options = {
                icons_enabled = true,
                theme = "auto",
                globalstatus = true, -- enable global statusline (single SL for all windows)
                always_divide_middle = true,
                section_separators = {left = "", right = ""},
                component_separators = {left = "", right = ""},
                disabled_filetypes = {
                    -- "help",
                    "NvimTree",
                    "coc-explorer",
                    "quickmenu",
                    "undotree",
                    "neoterm",
                    "floaterm"
                }
            },
            sections = sections_1,
            inactive_sections = {
                lualine_a = {},
                lualine_b = {
                    {"filetype", icon_only = false},
                    {
                        "filesize",
                        cond = conditions.hide_in_width,
                        color = {fg = colors.green}
                    },
                    plugins.file_encoding,
                    {
                        "filename",
                        path = 0,
                        symbols = {
                            modified = icons.misc.modified,
                            readonly = icons.misc.readonly,
                            unnamed = icons.misc.unnamed
                        },
                        color = function(section)
                            -- return { fg = vim.bo.modified and colors.purple or colors.fg }
                            return {gui = vim.bo.modified and "bold" or "none"}
                        end
                    }
                },
                lualine_c = {},
                lualine_x = {"location"},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            -- tabline = {
            --   lualine_a = { "tabs" },
            --   lualine_b = { { "buffers" } },
            --   lualine_c = {},
            --   lualine_x = {},
            --   lualine_y = {},
            --   lualine_z = {
            --     {
            --       'require("nvim-gps").get_location()',
            --       cond = conditions.is_available_gps,
            --     },
            --   },
            -- },
            extensions = {
                -- "quickfix",
                my_qf,
                my_toggleterm,
                "symbols-outline",
                my_extension,
                "aerial",
                "fzf",
                "fugitive"
            }
        }
    )
end

init()

return M
