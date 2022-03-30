-- TODO: Show tab numbers (buffers)
local utils = require("common.utils")
local map = utils.map

-- ========================== Custom ==========================
local colors = {
  ocean = "#221a02",
  black = "#291804",
  red = "#DC3958",
  red2 = "#EF1D55",
  green = "#819C3B",
  yellow = "#FF9500",
  orange = "#FF5813",
  blue = "#4C96A8",
  magenta = "#A06469",
  purple = "#98676A",
  cyan = "#7EB2B1",
  white = "#e8c097",
  fg = "#D9AE80",
  bg = "#221a02",
  gray1 = "#a89984",
  brown1 = "#7E602C",
  brown2 = "#5e452b",
  brown3 = "#362712",
}

local kimbox = {
  normal = {
    a = { fg = colors.purple, bg = colors.bg, gui = "bold" },
    b = { fg = colors.fg, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.brown3 },
    x = { fg = colors.fg, bg = colors.bg },
  },
  command = { a = { fg = colors.blue, bg = colors.bg, gui = "bold" } },
  inactive = {
    a = { fg = colors.red, bg = colors.bg },
    b = { fg = colors.magenta, bg = colors.bg },
  },
  insert = { a = { fg = colors.green, bg = colors.bg, gui = "bold" } },
  replace = { a = { fg = colors.red, bg = colors.bg, gui = "bold" } },
  terminal = { a = { fg = colors.yellow, bg = colors.bg, gui = "bold" } },
  visual = { a = { fg = colors.orange, bg = colors.bg, gui = "bold" } },
}

local conditions = {
  -- Show function in statusbar
  is_available_gps = function()
    local ok, _ = pcall(require, "nvim-gps")
    if not ok then
      return false
    end
    return require("nvim-gps").is_available()
  end,

  hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
}

local plugins = {
  -- Show function is statusbar with vista
  vista_nearest_method = function()
    -- vim.cmd [[autocmd VimEnter * call vista#RunForNearestMethodOrFunction()]]
    return vim.b.vista_nearest_method_or_function
  end,

  file_encoding = function()
    local encoding = vim.opt.fileencoding:get()
    if encoding == "utf-8" then
      return ""
    else
      return encoding
    end
  end,

}

local sections_1 = {
  lualine_a = { "mode" },
  lualine_b = {
    { "filetype", icon_only = false },
    { "filesize", cond = conditions.hide_in_width },
    plugins.file_encoding,
    {
      "filename",
      path = 1,
      symbols = { modified = "[+]", readonly = " ", unnamed = "[No name]" },
    },
  },
  lualine_c = { "g:coc_status" },
  lualine_x = {
    {
      "diagnostics",
      sources = { "coc" },
      symbols = { error = " ", warn = " ", info = " ", hint = " " },
    },
  },
  lualine_y = { "branch", { "diff", cond = conditions.hide_in_width } },
  lualine_z = { "progress", "location" },
}

local sections_2 = {
  lualine_a = { "mode" },
  lualine_b = { "" },
  lualine_c = { { "filetype", icon_only = true }, { "filename", path = 1 } },
  lualine_x = { "fileformat", "filetype" },
  lualine_y = { "filesize", "progress" },
  lualine_z = { "location" },
}

function LualineToggle()
  local lualine_require = require("lualine_require")
  local modules = lualine_require.lazy_require(
      { config_module = "lualine.config" }
  )
  local utils = require("lualine.utils.utils")

  local current_config = modules.config_module.get_config()
  if vim.inspect(current_config.sections) == vim.inspect(sections_1) then
    current_config.sections = utils.deepcopy(sections_2)
  else
    current_config.sections = utils.deepcopy(sections_1)
  end
  require("lualine").setup(current_config)
end

map("n", "!", ":lua LualineToggle()<CR>", { silent = true })

-- ========================== Terminal ==========================

local terminal_status_color = function(status)
  local mode_colors = {
    Running = colors.orange,
    Finished = colors.purple,
    Success = colors.blue,
    Error = colors.red,
    Command = colors.magenta,
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
  if vim.api.nvim_exec(
      [[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaF"))]],
      true
  ) ~= "" then
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
  if vim.api.nvim_exec(
      [[echo trim(execute("filter /" . escape(nvim_buf_get_name(bufnr()), '~/') . "/ ls! uaR"))]],
      true
  ) ~= "" then
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
      "hi LualineToggleTermStatus guifg=" .. colors.background .. " guibg=" ..
          terminal_status_color(status)
  )
  return status
end

local function toggleterm_statusline()
  return "ToggleTerm #" .. vim.b.toggle_number
end

local my_toggleterm = {
  sections = {
    lualine_a = { toggleterm_statusline },
    lualine_z = { { get_terminal_status, color = "LualineToggleTermStatus" } },
  },
  filetypes = { "toggleterm" },
}

local my_extension = {
  sections = { lualine_b = { "filetype" } },
  filetypes = { "packager", "vista", "NvimTree", "coc-explorer" },
}

require("lualine").setup(
    {
      options = {
        icons_enabled = true,
        theme = kimbox,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        -- Not sure if these work
        disabled_filetypes = {
          "NvimTree",
          "coc-explorer",
          "help",
          "quickmenu",
          "undotree",
          "neoterm",
          "floaterm",
          "qf",
        },
        always_divide_middle = true,
      },
      sections = sections_1,
      inactive_sections = {
        lualine_a = { "mode" },
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
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
        "fzf",
      },
    }
)
