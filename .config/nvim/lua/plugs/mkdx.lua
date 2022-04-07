local M = {}

require("common.utils")
local K = require("common.keymap")

function M.setup()
  g["mkdx#settings"] = {
    restore_visual = 1,
    gf_on_steroids = 1,
    highlight = { enable = 1 },
    enter = { shift = 1 },
    map = { prefix = "M", enable = 1 },
    links = { external = { enable = 1 } },
    checkbox = { toggles = { " ", "x", "-" } },
    tokens = { strike = "~~", list = "*" },
    fold = { enable = 1, components = { "toc", "fence" } },
    toc = {
      text = "Table of Contents",
      update_on_write = 1,
      details = { nesting_level = 0 },
    },
  }
end

local function init()
  -- M.setup()

  cmd [[
    let g:mkdx#settings     = {
          \ 'restore_visual': 1,
          \ 'gf_on_steroids': 1,
          \ 'highlight': { 'enable':   1 },
          \ 'enter':     { 'shift':    1 },
          \ 'map':       { 'prefix': "'", 'enable': 1 },
          \ 'links':     { 'external': { 'enable': 1 } },
          \ 'checkbox':  {'toggles': [' ', 'x', '-'] },
          \ 'tokens':    { 'strike': '~~',
          \                'list': '*' },
          \ 'fold':      { 'enable':   1,
          \                'components': ['toc', 'fence'] },
          \ 'toc': {
          \    'text': 'Table of Contents',
          \    'update_on_write': 1,
          \    'details': { 'nesting_level': 0 }
          \ }
          \ }
   ]]
end

init()

return M
