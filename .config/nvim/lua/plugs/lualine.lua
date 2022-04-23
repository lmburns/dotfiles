local utils = require("common.utils")
local map = utils.map

-- ========================== Custom ==========================

local colors = require("kimbox.lualine").colors()

local conditions = {
    -- Show function in statusbar
    is_available_gps = function()
        local ok, _ = pcall(require, "nvim-gps")
        if not ok then
            return false
        end
        return require("nvim-gps").is_available()
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    -- TODO: Make this better
    coc_status_width = function()
        if fn.exists("g:coc_status") then
            if fn.strwidth("g:coc_status") > 30 then
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

local plugins = {
    -- Show function is statusbar with vista
    vista_nearest_method = function()
        -- vim.cmd [[autocmd VimEnter * call vista#RunForNearestMethodOrFunction()]]
        return vim.b.vista_nearest_method_or_function
    end,
    gutentags_progress = function()
        return vim.fn["gutentags#statusline"]("[", "]")
    end,
    luapad = function()
        local status = fn["luapad#lightline_status"]()
        local msg = fn["luapad#lightline_msg"]

        if status == "OK" then
            return ("%s - %s"):format(status, msg)
        else
            return ""
        end
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
        local last_search = vim.fn.getreg("/")
        if not last_search or last_search == "" then
            return ""
        end
        local searchcount = vim.fn.searchcount {maxcount = 9999}
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
    end
}

local sections_1 = {
    lualine_a = {
        {
            "mode",
            -- Doesn't show operator mode?
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
            path = 1,
            symbols = {modified = "[+]", readonly = "[] ", unnamed = "[No name]"}
        },
        {
            "%w",
            cond = function()
                return vim.wo.previewwindow
            end
        },
        {
            "%q",
            cond = function()
                return vim.bo.buftype == "quickfix"
            end
        }
    },
    lualine_c = {"g:coc_status"},
    lualine_x = {
        {
            'require("nvim-gps").get_location()',
            cond = conditions.is_available_gps and conditions.hide_in_width and conditions.coc_status_width,
            color = {fg = colors.red}
        },
        {
            "diagnostics",
            sources = {"coc"},
            symbols = {error = " ", warn = " ", info = " ", hint = " "}
        }
    },
    lualine_y = {
        {"diff", cond = conditions.hide_in_width},
        {plugins.luapad}
    },
    lualine_z = {"%l:%c", "%p%%/%L"}
}

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
            symbols = {modified = "[+]", readonly = " ", unnamed = "[No name]"}
        }
    },
    lualine_c = {},
    lualine_x = {
        {
            'require("nvim-gps").get_location()',
            cond = conditions.is_available_gps,
            color = {fg = colors.red}
        },
        {"branch", icon = "", condition = conditions.check_git_workspace}
    },
    lualine_y = {plugins.progress, plugins.gutentags_progress},
    lualine_z = {"location"}
}

function LualineToggle()
    local lualine_require = require("lualine_require")
    local modules = lualine_require.lazy_require({config_module = "lualine.config"})
    local utils = require("lualine.utils.utils")

    local current_config = modules.config_module.get_config()
    if vim.inspect(current_config.sections) == vim.inspect(sections_1) then
        current_config.sections = utils.deepcopy(sections_2)
    else
        current_config.sections = utils.deepcopy(sections_1)
    end
    require("lualine").setup(current_config)
end

map("n", "!", ":lua LualineToggle()<CR>", {silent = true})

-- ========================== Terminal ==========================

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
    local ln = vim.api.nvim_buf_line_count(0)
    while ln >= 1 do
        local l = vim.api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
        ln = ln - 1
        local exit_code = string.match(l, "^%[Process exited ([0-9]+)%]$")
        if exit_code ~= nil then
            return tonumber(exit_code)
        end
    end
end

local terminal_status = function()
    if
        vim.api.nvim_exec(
            [[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaF"))]],
            true
        ) ~= ""
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
        vim.api.nvim_exec(
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
    vim.api.nvim_command(
        "hi LualineToggleTermStatus guifg=" .. colors.background .. " guibg=" .. terminal_status_color(status)
    )
    return status
end

local function toggleterm_statusline()
    return "ToggleTerm #" .. vim.b.toggle_number
end

local my_toggleterm = {
    sections = {
        lualine_a = {toggleterm_statusline},
        lualine_z = {{get_terminal_status, color = "LualineToggleTermStatus"}}
    },
    filetypes = {"toggleterm"}
}

local my_extension = {
    sections = {lualine_b = {"filetype"}},
    filetypes = {"packager", "vista", "NvimTree", "coc-explorer"}
}

require("lualine").setup(
    {
        options = {
            icons_enabled = true,
            -- theme = 'kimbox',
            theme = "auto",
            section_separators = {left = "", right = ""},
            component_separators = {left = "", right = ""},
            -- Not sure if these work
            disabled_filetypes = BLACKLIST_FT,
            always_divide_middle = true
        },
        sections = sections_1,
        inactive_sections = {
            lualine_a = {"mode"},
            lualine_b = {},
            lualine_c = {"filename"},
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
        --       "require(\"nvim-gps\").get_location()",
        --       cond = conditions.is_available_gps,
        --     },
        --   },
        -- },
        extensions = {
            "quickfix",
            my_toggleterm,
            "symbols-outline",
            my_extension,
            "fzf"
        }
    }
)
