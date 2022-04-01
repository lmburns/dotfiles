local M = {}

require("common.utils")
local K = require("common.keymap")

function M.setup()
  g["mkdx#settings"] = {
    restore_visual = 1,
    gf_on_steroids = 1,
    highlight = { enable = 1 },
    enter = { shift = 1 },
    map = { prefix = "m", enable = 1 },
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

function M.goto_header(header)
  api.nvim_win_set_cursor(
      fn.get(fn.matchlist(header, [[ *\([0-9]\+\)]]), 1, ""), 1
  )
end

function M.format_header(key, val)
  local text = fn.get(val, "text", "")
  local lnum = fn.get(val, "lnum", "")

  if text == "" or lnum == "" then
    return text
  end

  return string.rep(" ", 4 - #lnum) .. lnum .. ": " .. text
end

function M.quickfixheaders()
  -- cmd [[
  --   let headers = filter(
  --     \ map(mkdx#QuickfixHeaders(0),function('s:MkdxFormatHeader')),
  --     \ 'v:val != ""'
  --     \ )
  --
  --   call fzf#run(fzf#wrap({
  --     \ 'source': headers,
  --     \ 'sink': function('s:MkdxGoToHeader')
  --     \ }))
  -- ]]
end

local function init()
  M.setup()

  cmd [[
    function! MkdxGoToHeader(header)
      call cursor(str2nr(get(matchlist(a:header, ' *\([0-9]\+\)'), 1, '')), 1)
    endfunction

    function! MkdxFormatHeader(key, val)
      let text = get(a:val, 'text', '')
      let lnum = get(a:val, 'lnum', '')

      if (empty(text) || empty(lnum)) | return text | endif
      return repeat(' ', 4 - strlen(lnum)) . lnum . ': ' . text
    endfunction

    function! MkdxFzfQuickfixHeaders()
      let headers = filter(
        \ map(mkdx#QuickfixHeaders(0),function('MkdxFormatHeader')),
        \ 'v:val != ""'
        \ )

      call fzf#run(fzf#wrap({
        \ 'source': headers,
        \ 'sink': function('MkdxGoToHeader')
        \ }))
    endfunction

    nnoremap <silent> <Leader>I :call MkdxFzfQuickfixHeaders()<CR>
   ]]

  -- map("n", "<Leader>I", [[v:lua require'plugs.mkdx'.quickfixheaders()]])
end

init()

return M
