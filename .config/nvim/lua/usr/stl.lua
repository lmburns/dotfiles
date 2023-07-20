---@module 'usr.stl'
local M = {}

M.plugins = {}
M.builtin = {}
M.extensions = {}
M.conditions = {}
M.other = {}

local utils = Rc.shared.utils
local mod = utils.mod
local xprequire = mod.xprequire
local gittool = utils.git
local F = Rc.F
local hl = Rc.shared.hl

local B = Rc.api.buf
local I = Rc.icons
local llicons = Rc.style.plugins.lualine

local lazy = require("usr.lazy")
local devicons = lazy.require("nvim-web-devicons")
local coc = lazy.require("plugs.coc")
local colors = lazy.require("kimbox.colors")

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
        if mod.loaded("nvim-gps") then
            return require("nvim-gps").is_available()
        end
        return false
    end,
    hide_in_width = function()
        return fn.winwidth(0) > 80
    end,
    coc_status_width = function()
        if fn.exists("g:coc_status") == 1 and g.coc_status then
            if #g.coc_status > 28 then
                return false
            end
        end
        return true
    end,
    buffer_not_empty = function()
        return not B.buf_is_empty()
    end,
    has_file_type = function()
        return vim.bo.ft and not vim.bo.ft == ""
    end,
    check_git_workspace = function()
        -- local filepath = fn.expand("%:p:h")
        -- local gitdir = fn.finddir(".git", filepath .. ";")
        -- return gitdir and #gitdir > 0 and #gitdir < #filepath
        return #gittool.root() > 0
    end,
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Plugins
-- ╘══════════════════════════════════════════════════════════╛

M.plugins.sep = function()
    return llicons.sep.slant
end

M.plugins.recording = {
    fn = function()
        local reg = fn.reg_recording()
        if reg ~= "" then
            return ("Recording[%s]"):format(reg)
        end
        return ""
    end,
}

M.plugins.diff = {
    fn = function()
        local gs = vim.b.gitsigns_status_dict
        if gs then
            return {added = gs.added, modified = gs.changed, removed = gs.removed}
        end
        return {added = nil, modified = nil, removed = nil}
    end,
}

M.plugins.blame = {
    fn = function()
        if vim.b.gitsigns_blame_line_dict then
            local info = vim.b.gitsigns_blame_line_dict
            local date_time = require("gitsigns.util").get_relative_time(tonumber(info.author_time))
            return ("%s - %s"):format(info.author, date_time)
        end
        return ""
    end,
}

M.plugins.branch = {
    fn = function(opts)
        local settings = {
            -- "branch",
            -- "FugitiveHead",
            "b:gitsigns_head",
            icon = I.git.branch,
            cond = function()
                return M.conditions.check_git_workspace()
            end,
            color = F.if_expr(
                g.colors_name == "kimbox",
                {fg = colors.deep_saffron, gui = "bold"},
                {gui = "bold"}
            ),
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

M.plugins.gitbuf = {
    fn = function()
        -- local bufname = api.nvim_buf_get_name(0)
        -- local fugitive_name = vim.b.fugitive_fname
        -- if not fugitive_name then
        --     if bufname:match("^fugitive:") and fn.exists("*FugitiveReal") == 1 then
        --         fugitive_name = fs.basename(fn.FugitiveReal(bufname)) .. " "
        --         vim.b.fugitive_fname = fugitive_name
        --     end
        -- end
        -- return F.unwrap_or(fugitive_name, str)

        -- local name = api.nvim_eval_statusline("%f", {}).str
        local name = ""
        local bufname = api.nvim_buf_get_name(0)
        if bufname:match("^fugitive:") then
            local _, _, commit, relpath = bufname:find([[^fugitive://.*/%.git.*/(%x-)/(.*)]])
            -- return ("fugitive@%s"):format(commit:sub(1, 7))
            name = relpath .. "@" .. commit:sub(1, 7)
        end
        if bufname:match("^gitsigns:") then
            local _, _, revision, relpath = bufname:find([[^gitsigns://.*/%.git.*/(.*):(.*)]])
            -- return ("gitsigns@%s"):format(revision:sub(1, 7))
            name = relpath .. "@" .. revision:sub(1, 7)
        end

        return name
    end,
}

-- p(api.nvim_eval_statusline('+ 10', {}))

M.plugins.coc_status = {
    fn = function()
        local _
        local s = vim.trim(g.coc_status or "")
        s, _ --[[@as any]] = s:gsub("%%", "%%%%")
        return s
    end,
}

---Display an icon if spelling is on
M.plugins.spell = {
    toggle = function()
        return api.nvim_get_option_value("spell", {win = 0})
    end,
    fn = ([[%s]]):format(I.misc.spell),
}

M.plugins.wrap = {
    toggle = function()
        return api.nvim_get_option_value("wrap", {win = 0})
    end,
    fn = [[%"w]],
}

---Display 'foldlevel'
M.plugins.foldlevel = {
    ---@return string
    toggle = function()
        return api.nvim_get_option_value("foldlevel", {win = 0})
    end,
    ---@return string
    fn = function()
        return ("%s %s"):format(I.misc.fold, vim.o.foldlevel)
    end,
}

M.plugins.location = {
    ---@return table
    fn = function(opts, icon)
        icon = F.unwrap_or(icon, true)
        local str = icon and "%3l%-2v" or "%3l:%-2v"
        local settings = {
            str,
            fmt = function(s)
                if icon then
                    return ("%s %s"):format(I.misc.line, s)
                end
                return s
            end,
            color = {fg = colors.slate_grey, gui = "bold"},
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

---Show space information about the buffer
M.plugins.space_info = function()
    return "%{&expandtab?'Spc:'.&shiftwidth:'Tab:'.&shiftwidth}"
end

M.plugins.file_encoding = {
    ---@return boolean
    toggle = function()
        local encoding = vim.o.fileencoding
        return encoding ~= "utf-8"
    end,
    ---@return string
    fn = function()
        return vim.o.fileencoding
    end,
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
    end,
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
            "██",
        }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)
        return chars[index]
    end,
}

---Show number of items in locationlist
M.plugins.loclist_count = {
    ---@return string
    fn = function()
        local ll = fn.getloclist(fn.winnr(), {idx = 0, size = 0})
        local count = ll.size
        local current = ll.idx
        return count == 0 and "" or ("%s %d/%d "):format(I.misc.loclist, current, count)
    end,
}

---Show number of items in quickfix
M.plugins.quickfix_count = {
    ---@return string
    fn = function()
        local qf = fn.getqflist({idx = 0, size = 0})
        local count = qf.size
        local current = qf.idx
        return count == 0 and "" or ("%s %d/%d "):format(I.misc.quickfix, current, count)
    end,
}

-- FIX: Runs way to often
---Show number of TODO comments in buffer
M.plugins.todo_comment_count = {
    toggle = function()
        return mod.loaded("todo-comments.nvim")
    end,
    fn = function()
        return require("plugs.todo-comments").get_todo_count()
    end,
}

---Show function is statusbar with vista
M.plugins.vista_nearest_method = {
    toggle = function()
        return mod.loaded("vista.vim")
    end,
    fn = function()
        return vim.b.vista_nearest_method_or_function
    end,
}

M.plugins.coc_function = {
    toggle = function()
        return g.coc_current_function ~= nil
    end,
    fn = function()
        return g.coc_current_function
    end,
}

M.plugins.gutentags_progress = {
    toggle = function()
        return mod.loaded("vim-gutentags")
    end,
    fn = function()
        return fn["gutentags#statusline"]("[", "]")
    end,
}

-- Visual Multi
M.plugins.vm = {
    toggle = function()
        return fn.exists("b:VM_Selection") == 1 and fn.empty("b:VM_Selection") == 0
    end,
    fn = function()
        local vm_infos = fn.VMInfos()
        return ("%s [%s/%s] [%s]"):format(
            F.if_expr(require("plugs.vm").mode() == 1, "VISUAL", "NORMAL"),
            vm_infos.current,
            vm_infos.total,
            vm_infos.patterns[1]
        )
    end,
}

M.plugins.vim_matchup = {
    fn = function()
        return fn.MatchupStatusOffscreen()
    end,
}

-- M.plugins.noice = {
--     command = {
--         toggle = function()
--             return xprequire("noice").api.status.command.has()
--         end,
--         fn = function()
--             return xprequire("noice").api.status.command.get()
--         end,
--     },
-- }

-- nvim-gps
M.plugins.gps = {
    toggle = function()
        return mod.loaded("nvim-gps")
    end,
    fn = function()
        local opts = {disable_icons = false}
        return require("nvim-gps").get_location(opts)
    end,
}

M.plugins.treesitter = {
    toggle = function()
        return mod.loaded("nvim-treesitter")
    end,
    fn = function()
        local opts = {
            indicator_size = 100,
            type_patterns = {"class", "function", "method"},
            transform_fn = function(line, _node)
                return line:gsub("%s*[%[%(%]*%s*$", "")
            end,
            separator = " -> ",
            allow_duplicates = false,
        }
        return fn["nvim_treesitter#statusline"](opts)
    end,
}

M.plugins.luapad = {
    toggle = function()
        return mod.loaded("nvim-luapad")
    end,
    fn = function()
        local status = fn["luapad#lightline_status"]()
        local msg = fn["luapad#lightline_msg"]

        if status == "OK" then
            return ("%s - %s"):format(status, msg)
        end

        return ""
    end,
}

M.plugins.debugger = {
    toggle = function()
        return mod.loaded("nvim-dap")
    end,
    fn = function()
        -- local session = require('dap').session()
        -- return session ~= nil and session.config ~= nil and session.config.type or ''
        return xprequire("dap").status()
    end,
}

--  ╒══════════════════════════════════════════════════════════╕
--                            Builtin
--  ╘══════════════════════════════════════════════════════════╛

M.builtin.diff = {
    fn = function(opts)
        local settings = {
            "diff",
            colored = true,
            diff_color = {
                added = "GitSignsAdd",       -- "DiffAdd",
                modified = "GitSignsChange", --  "DiffChange",
                removed = "GitSignsDelete",  -- "DiffDelete"
            },
            symbols = {added = I.git.add, modified = I.git.mod, removed = I.git.remove},
            source = M.plugins.diff.fn,
            -- separator = {left = ""}
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

M.builtin.filename = {
    fn = function(opts)
        local settings = {
            "filename",
            path = 0,
            file_status = true,
            newfile_status = true,
            shorting_target = 40,
            symbols = {
                modified = I.file.modified,
                readonly = I.file.readonly,
                unnamed = I.file.unnamed,
                newfile = I.file.newfile,
            },
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

M.builtin.filetype = {
    fn = function(opts)
        local settings = {
            "filetype",
            icon_only = true,
            colored = true,
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

M.builtin.filesize = {
    fn = function(opts)
        local settings = {
            "filesize",
            cond = function()
                return M.conditions.hide_in_width() and M.conditions.buffer_not_empty()
            end,
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

M.builtin.mode = {
    fn = function(opts, full)
        full = F.unwrap_or(full, false)
        local settings = {
            "mode",
            fmt = function(str)
                local ret = "%s "
                if full then
                    ret = ret:format(str)
                else
                    ret = ret:format(
                        (str == "V-LINE" and "VL") or (str == "V-BLOCK" and "VB") or str:sub(1, 1)
                    )
                end
                return ret .. M.plugins.sep()
            end,
            padding = M.other.only_pad_right,
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
}

M.builtin.selectioncount = {
    fn = function(opts)
        local settings = {
            "selectioncount",
            fmt = function(s)
                return s ~= "" and ("S:%s"):format(s) or ""
            end,
            color = {fg = colors.peach_red, gui = "bold"},
        }
        return vim.tbl_deep_extend("force", settings, opts or {})
    end,
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
        Command = colors.magenta,
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
        api.nvim_exec(
            [[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaF"))]],
            true
        ) ~= ""
    then
        local result = get_exit_status()
        if result == 0 then
            return "Success"
        elseif result >= 1 then
            return "Error"
        end
        return "Finished"
    end
    if
        api.nvim_exec(
            [[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaR"))]],
            true
        ) ~= ""
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
    hl.set("LualineToggleTermStatus", {
        fg = terminal_status_color(status),
        bg = colors.bg0,
        bold = true,
    })
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
        lualine_z = {{get_terminal_status, color = "LualineToggleTermStatus"}},
    },
    filetypes = {"toggleterm"},
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
            {quickfix, color = {fg = colors.green}},
            {"%p%% [%L]", color = {fg = colors.orange, gui = "bold"}},
        },
        lualine_c = {{qf_cmd, color = {fg = colors.yellow}}},
    },
    filetypes = {"qf"},
}

--  ╒══════════════════════════════════════════════════════════╕
--                              Man
--  ╘══════════════════════════════════════════════════════════╛

M.extensions.man = {
    sections = {
        lualine_a = {
            function()
                return ("man %s"):format(M.plugins.sep())
            end,
        },
        lualine_b = {
            M.builtin.filename.fn({
                path = 0,
                file_status = false,
                newfile_status = false,
                color = {fg = colors.green, gui = "bold"},
            }),
        },
        lualine_y = {},
        lualine_z = {
            {
                M.plugins.quickfix_count.fn,
                separator = {left = M.plugins.sep()},
                color = {fg = colors.oni_violet, gui = "bold"},
            },
            {
                M.plugins.loclist_count.fn,
                separator = {left = M.plugins.sep()},
                color = {fg = colors.oni_violet, gui = "bold"},
            },
            M.builtin.selectioncount.fn(),
            M.plugins.location.fn(),
            {"progress"},
        },
    },
    filetypes = {"man"},
}

M.extensions.diffview = {
    sections = {
        lualine_a = {
            {
                function()
                    return (" %s"):format(M.plugins.sep())
                end,
            },
            M.plugins.branch.fn(),
        },
        lualine_b = {M.builtin.diff.fn()},
        lualine_y = {},
        lualine_z = {
            {
                M.plugins.quickfix_count.fn,
                separator = {left = M.plugins.sep()},
                color = {fg = colors.oni_violet, gui = "bold"},
            },
            {
                M.plugins.loclist_count.fn,
                separator = {left = M.plugins.sep()},
                color = {fg = colors.oni_violet, gui = "bold"},
            },
            M.builtin.selectioncount.fn(),
            M.plugins.location.fn(),
            {"progress"},
        },
    },
    filetypes = {
        "DiffviewFileStatus",
        "DiffviewFileHistoryPanel",
    },
}

M.extensions.neogit = {
    sections = {
        lualine_a = {
            {
                function()
                    local branch = ""
                    local status = require("neogit.status")
                    if status and status.repo and status.repo.head then
                        branch = status.repo.head.branch
                    end
                    return branch
                end,
                icon = I.git.branch,
            },
        },
        lualine_b = {
            -- M.builtin.diff.fn()
        },
        lualine_y = {},
        lualine_z = {
            {
                M.plugins.quickfix_count.fn,
                separator = {left = M.plugins.sep()},
                color = {fg = colors.oni_violet, gui = "bold"},
            },
            {
                M.plugins.loclist_count.fn,
                separator = {left = M.plugins.sep()},
                color = {fg = colors.oni_violet, gui = "bold"},
            },
            M.builtin.selectioncount.fn(),
            M.plugins.location.fn(),
            {"progress"},
        },
    },
    filetypes = {
        "NeogitCommitMessage",
        "NeogitCommitView",
        "NeogitGitCommandHistory",
        "NeogitLogView",
        "NeogitNotification",
        "NeogitPopup",
        "NeogitStatus",
        "NeogitStatusNew",
        "NeogitRebaseTodo",
        "NeogitCommitHistory",
        "NeogitLog",
        "NeogitMergeMessage",
    },
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Trouble
-- ╘══════════════════════════════════════════════════════════╛

function M.document_diagnostics()
    local diagnostics = {}
    -- Maybe a better way to get previous buffer
    -- Would also be nice to distinguish between workspace and document
    ---@diagnostic disable-next-line: param-type-mismatch
    local bufnr = fn.bufnr("#")

    if not coc.did_init() then
        return diagnostics
    end

    -- Use a default {} to prevent indexing errors
    local data = vim.b[bufnr].coc_diagnostic_info or {}
    return {
        error = F.unwrap_or(data.error, 0),
        warn = F.unwrap_or(data.warning, 0),
        info = F.unwrap_or(data.information, 0),
        hint = F.unwrap_or(data.hint, 0),
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
        lualine_a = {M.builtin.mode.fn()},
        lualine_b = {
            {
                "filetype",
                fmt = function(str)
                    return ("[%s] %s"):format(I.misc.loclist, str)
                end,
                color = {fg = colors.red, gui = "bold"},
            },
        },
        lualine_c = {
            {
                "diagnostics",
                sources = {M.document_diagnostics},
                symbols = {
                    error = I.lsp.sb.error,
                    warn = I.lsp.sb.warn,
                    info = I.lsp.sb.info,
                    hint = I.lsp.sb.hint,
                },
            },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
            "%l:%c",
            "%p%%/%L",
        },
    },
    filetypes = {"Trouble"},
}

return M
