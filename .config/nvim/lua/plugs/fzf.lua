local M = {}

local mru = require("common.mru")
local cutils = require("common.utils")
local utils = require("common.kutils")

local coc = require("plugs.coc")
local map = cutils.map

local default_preview_window, default_action

local function build_opt(opts)
  local preview_args = vim.g.fzf_preview_window or default_preview_window
  return fn["fzf#vim#with_preview"](opts, unpack(preview_args))
end

local function do_action(expect, path, bufnr, lnum, col)
  local action = vim.g.fzf_action or {}
  action = vim.tbl_extend("keep", action, default_action)
  local jump_cmd = action[expect] or "edit"
  local bi
  if jump_cmd == "drop" then
    if not bufnr then
      bufnr = fn.bufadd(path)
      vim.bo[bufnr].buflisted = true
    end
    bi = fn.getbufinfo(bufnr)
    if #bi == 1 and #bi[1].windows == 0 then
      api.nvim_set_current_buf(bufnr)
      return
    end
  end

  local function jump_path(p)
    cmd(("%s %s"):format(jump_cmd, fn.fnameescape(p)))
  end

  if path == "" then
    if bufnr and bufnr > 0 and api.nvim_buf_is_valid(bufnr) then
      local tmpfile = fn.tempname()
      local tmp_bufnr = fn.bufadd(tmpfile)
      if jump_cmd:match("drop") then
        bi = bi or fn.getbufinfo(bufnr)
        if #bi == 1 then
          local winids = bi[1].windows
          if #winids > 0 then
            fn.win_gotoid(winids[1])
            cmd(("keepalt b %d"):format(tmp_bufnr))
          else
            jump_path(tmpfile)
          end
        end
      else
        jump_path(tmpfile)
      end
      cmd(("keepalt b %d"):format(bufnr))
      cmd(("noa bw %d"):format(tmp_bufnr))
    end
  else
    jump_path(path)
  end

  if lnum then
    col = col or 1
    api.nvim_win_set_cursor(0, { lnum, col - 1 })
  end
end

local function format_files(b_list, m_list)
  local max_bufnr = 0
  local b_names = {}
  for _, b in ipairs(b_list) do
    b_names[b.name] = true
    if max_bufnr < b.bufnr then
      max_bufnr = b.bufnr
    end
  end
  local max_digit = math.floor(math.log10(max_bufnr)) + 1
  local cur_bufnr, alt_bufnr = api.nvim_get_current_buf(), fn.bufnr("#")
  local fmt = "%s:%d\t%d\t%s[%s]\t%s"
  local out = {}
  for _, b in ipairs(b_list) do
    local bufnr = b.bufnr
    local bt = vim.bo[bufnr].bt
    if bt ~= "help" and bt ~= "quickfix" and bt ~= "terminal" and bt ~= "prompt" then
      local name = b.name
      local lnum = b.lnum
      local readonly = vim.bo[bufnr].readonly
      local modified = b.changed == 1
      local flag = ""
      if modified then
        flag = utils.ansi.Statement:format("+ ")
      elseif readonly then
        flag = utils.ansi.Special:format("- ")
      end

      local sname = name == "" and "[No name]" or fn.fnamemodify(name, ":~:.")
      if bufnr == cur_bufnr then
        sname = utils.ansi.Directory:format(sname)
      elseif bufnr == alt_bufnr then
        sname = utils.ansi.Constant:format(sname)
      end

      sname = flag .. sname
      local bufnr_str = utils.ansi.Number:format(tostring(bufnr))
      local digit = math.floor(math.log10(bufnr)) + 1
      local padding = (" "):rep(max_digit - digit)
      local o_str = fmt:format(name, lnum, lnum, padding, bufnr_str, sname)

      table.insert(out, o_str)
    end
  end

  fmt = "%s:1\t1\t" .. (" "):rep(max_digit + 2) .. "\t%s"
  for _, m in ipairs(m_list) do
    if not b_names[m] then
      local sname = fn.fnamemodify(m, ":~:.")
      local o_str = fmt:format(m, sname)
      table.insert(out, o_str)
    end
  end
  return out
end

-- TODO: Fix opening files from this
function M.files()
  local cur_bufnr = api.nvim_get_current_buf()

  local expr =
      [[{"bufnr": v:val.bufnr, "name": v:val.name, "lnum": v:val.lnum, ]] ..
          [["lastused": v:val.lastused, "changed": v:val.changed}]]
  local b_list = api.nvim_eval(
      ([[map(getbufinfo({'buflisted':1}), %q)]]):format(
          expr
      )
  )
  table.sort(b_list, function(a, b) return a.lastused > b.lastused end)
  local m_list = mru.list()
  local header = #b_list > 0 and b_list[1].bufnr == cur_bufnr and "1" or "0"
  local opts = {
    options = {
      "+m",
      "--prompt",
      "Files> ",
      "--tiebreak",
      "index",
      "--header-lines",
      header,
      "--ansi",
      "-d",
      "\t",
      "--tabstop",
      "1",
      "--with-nth",
      "3..",
      "--preview-window",
      "+{2}/2",
    },
  }
  opts = build_opt(opts)
  opts.name = "files"
  opts.source = format_files(b_list, m_list)
  opts["sink*"] = function(lines)
    if #lines ~= 2 then
      return
    end
    local expect = lines[1]
    local g1, _, g3 = unpack(vim.split(lines[2], "\t"))
    local path = g1:match("^(.*):%d+$")
    local bufnr = tonumber(g3:match("%[(%d+)%]$"))
    do_action(expect, path, bufnr)
  end
  fn.FzfWrapper(opts)
end

-- TODO: Modify these for my fzf functions
-- local function format_outline(symbols)
--   local fmt = "%s:%d\t%d\t%d\t%s\t    %s%s"
--   local out = {}
--   local name = api.nvim_buf_get_name(0)
--   local hl_map = {
--     Function = "Function",
--     Method = "Function",
--     Interface = "Structure",
--     Struct = "Structure",
--     Class = "Structure",
--   }
--   for _, s in ipairs(symbols) do
--     local k = s.kind
--     local lnum = s.lnum
--     local col = s.col
--     local kind = utils.ansi[hl_map[k]]:format(("%-10s"):format(k))
--     local text = s.text
--     local level =
--         s.level > 0 and utils.ansi.NonText:format(("| "):rep(s.level)) or ""
--     local o_str = fmt:format(name, lnum, lnum, col, kind, level, text)
--     table.insert(out, o_str)
--   end
--   return out
-- end
--
-- function M.outline()
--   local syms = coc.run_command(
--       "kvs.symbol.docSymbols",
--       { "", { "Function", "Method", "Interface", "Struct", "Class" } }
--   )
--   local opts = {
--     options = {
--       "+m",
--       "--prompt",
--       "Outline> ",
--       "--tiebreak",
--       "index",
--       "--ansi",
--       "-d",
--       "\t",
--       "--tabstop",
--       "1",
--       "--with-nth",
--       "4..",
--       "--preview-window",
--       "+{2}/2",
--     },
--   }
--   opts = build_opt(opts)
--   opts.name = "outline"
--   opts.source = format_outline(syms)
--   opts["sink*"] = function(lines)
--     if #lines ~= 2 then
--       return
--     end
--     local expect = lines[1]
--     local g1, g2, g3 = unpack(vim.split(lines[2], "\t"))
--     local path = g1:match("^(.*):%d+$")
--     local lnum, col = tonumber(g2), tonumber(g3)
--     do_action(expect, path, nil, lnum, col)
--   end
--   fn.FzfWrapper(opts)
-- end

-- function M.cmdhist()
--   local opts = {
--     name = "history-command",
--     source = cmdhist.list(),
--     ["sink*"] = function(ret)
--       local key, cmdl = unpack(ret)
--       if key == "ctrl-y" then
--         fn.setreg(vim.v.register, cmdl)
--       else
--         fn.histadd(":", cmdl)
--         cmdhist.store()
--         if key == "ctrl-e" then
--           cmd("redraw")
--           api.nvim_feedkeys(":" .. utils.termcodes["<Up>"], "n", false)
--         else
--           api.nvim_feedkeys((":" .. cmdl .. utils.termcodes["<CR>"]), "", false)
--         end
--       end
--     end,
--     options = {
--       "+m",
--       "--prompt",
--       "Hist: ",
--       "--tiebreak",
--       "index",
--       "--expect",
--       "ctrl-e,ctrl-y",
--     },
--   }
--   fn.FzfWrapper(opts)
-- end

-- \ 'source': 'copyq eval -- "tab(\"&clipboard\"); for(i=size(); i>0; --i) print(str(read(i-1)) + \"\n\");" \| tac',
-- \ 'options': '--no-border',
-- \ 'reducer': { line -> substitute(line[0], '^ *[0-9]\+ ', '', '') },
-- \ 'window': 'call FloatingFZF()'})

function M.copyq_fzf()
  local opts = {
    name = "copy-clipboard",
    source = (function()
      local ret = {}
      local val = require("lutils").capture(
        [[copyq eval -- 'tab("&clipboard"); for(i=size(); i>0; --i) print(str(read(i-1)) + "\0");']]
        )

      for v in val:gmatch("[^%z]+") do
        table.insert(ret, v)
      end
      return ret
    end)(),
    options = { "+m", "--prompt", "Copyq> ", "--tiebreak", "index" },
  }

  fn.FzfWrapper(opts)
end

function M.resize_preview_layout()
  local layout = vim.g.fzf_layout.window
  if vim.o.columns * layout.width - 2 > 100 then
    vim.g.fzf_preview_window = { "right:50%,border-left" }
  else
    if vim.o.lines * layout.height - 2 > 25 then
      vim.g.fzf_preview_window = { "down:50%,border-top" }
    else
      vim.g.fzf_preview_window = { "down:50%,border-top,hidden" }
    end
  end
end

function M.prepare_ft()
  -- TODO there's a bug for neovim's floating window for cursorline when split window, keep
  -- cursorline option of fzf's window on as a workaround
  vim.wo.cul = true
  for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
    local bt = vim.bo[api.nvim_win_get_buf(winid)].bt
    if bt == "quickfix" then
      return
    end
  end

  require("common.shadowwin").create()
  cmd(
      [[
        aug Fzf
            au BufWipeout <buffer> lua require('common.shadowwin').close()
            au VimResized <buffer> lua require('common.shadowwin').resize()
        aug END
    ]]
  )

end

local function init()
  g.rg_highlight = "true"
  g.rg_format = "%f:%l:%c:%m,%f:%l:%m"

  -- g.fzf_layout = { window = "call FloatingFZF()" }
  g.fzf_layout = { window = { width = 0.8, height = 0.8 } }

  g.fzf_history_dir = "~/.local/share/fzf-history"
  g.fzf_vim_opts = { options = { "--no-border" } }
  g.fzf_buffers_jump = 1
  g.fzf_action = {
    ["ctrl-t"] = "tab drop",
    ["ctrl-s"] = "split",
    ["ctrl-m"] = "edit",
    ["alt-v"] = "vsplit",
    ["alt-t"] = "nabnew",
    ["alt-x"] = "split",
  }

  env.FZF_PREVIEW_PREVIEW_BAT_THEME = "kimbro"
  g.fzf_preview_window = { "right:50%,border-left", "ctrl-/" }
  g.fzf_preview_quit_map = 1
  g.fzf_preview_use_dev_icons = 1
  g.fzf_preview_dev_icon_prefix_string_length = 3
  g.fzf_preview_dev_icons_limit = 2000
  -- g.fzf_preview_fzf_preview_window_option = 'nohidden'
  g.fzf_preview_default_fzf_options = {
    ["--no-border"] = true,
    ["--reverse"] = true,
    ["--preview-window"] = "wrap",
  }

  cmd("packadd fzf")
  cmd("packadd fzf.vim")

  -- Hide status and ruler for fzf
  -- cmd [[
  --   au FileType fzf
  --     \ set laststatus& laststatus=0 |
  --     \ au BufLeave <buffer> set laststatus&
  -- ]]

  -- Colors
  cmd [[command! -bang Colors call fzf#vim#colors(g:fzf_vim_opts, <bang>0)]]

  -- Files
  cmd [[
    command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>,
      \ fzf#vim#with_preview(g:fzf_vim_opts, 'right:60%:default'), <bang>0)
  ]]

  -- Buffers
  cmd [[
  command! -bang Buffers
    \ call fzf#vim#buffers(
    \ fzf#vim#with_preview(g:fzf_vim_opts, 'right:60%:default'), <bang>0)
  ]]

  -- LS
  cmd [[
  command! -bang -complete=dir -nargs=? LS
    \ call fzf#run(fzf#wrap({'source': 'ls', 'dir': <q-args>}, <bang>0))
  ]]

  -- Conf
  cmd [[
  command! -bang Conf
    \ call fzf#vim#files('~/.config', <bang>0)
  ]]

  -- Proj
  cmd [[
  command! -bang Proj
    \ call fzf#vim#files('~/projects', fzf#vim#with_preview(), <bang>0)
  ]]

  -- AF
  cmd [[
  command! -nargs=? -complete=dir AF
    \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
      \ 'source': 'fd --type f --hidden --follow --exclude .git --no-ignore
      \ . '.expand(<q-args>) })))
  ]]

  -- Rg
  cmd [[
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
      \ 'rg --column --line-number --hidden --smart-case '
        \ . '--no-heading --color=always '
        \ . shellescape(<q-args>),
        \ 1,
        \ {'options':  '--delimiter : --nth 4..'},
        \ 0)
  ]]

  -- Rgf
  cmd [[
    command! -bang -nargs=* Rgf call RGF()
    function! RGF()
      " . ' -F '.expand('%:t')"
      let fixmestr =
        \ '(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|HACK|BUG|BUGS):'
      call fzf#vim#grep(
        \ 'rg --column --no-heading --line-number --color=always '.shellescape(fixmestr),
        \ 1,
        \ {'options':  '--delimiter : --nth 4..'}, 0)
    endfunction
  ]]

  -- RipgrepFzf
  cmd [[
    command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
    function! RipgrepFzf(query, fullscreen)
      let command_fmt = 'rg --column --line-number --no-heading '
        \ . '--color=always --smart-case -- %s || true'
      let initial_command = printf(command_fmt, shellescape(a:query))
      let reload_command = printf(command_fmt, '{q}')
      let spec = {'options':
        \ ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
      call fzf#vim#grep(initial_command, 1,
        \ fzf#vim#with_preview(spec, 'right:60%:default'), a:fullscreen)
    endfunction
  ]]

  -- Dots
  cmd [[
    command! Dots call fzf#run(fzf#wrap({
      \ 'source': 'dotbare ls-files --full-name --directory "${DOTBARE_TREE}" '
        \ . '| awk -v home="${DOTBARE_TREE}/" "{print home \$0}"',
      \ 'sink': 'e',
      \ 'options': [ '--multi', '--preview', 'cat {}' ]
      \ }))
  ]]

  -- PlugHelp
  cmd [[
  function! s:plug_help_sink(line)
    let dir = g:plugs[a:line].dir
    for pat in ['doc/*.txt', 'README.md']
      let match = get(split(globpath(dir, pat), "\n"), 0, '')
      if len(match)
        execute 'tabedit' match
        return
      endif
    endfor
    tabnew
    execute 'Explore' dir
  endfunction

  command! PlugHelp call fzf#run(fzf#wrap({
    \ 'source': sort(keys(g:plugs)),
    \ 'sink':   function('s:plug_help_sink')}))
]]

  -- Apropos
  cmd [[
  command! -nargs=? Apropos call fzf#run(fzf#wrap({
      \ 'source': 'apropos '
          \ . (len(<q-args>) > 0 ? shellescape(<q-args>) : ".")
          \ .' | cut -d " " -f 1',
      \ 'sink': 'tab Man',
      \ 'options': [
          \ '--preview', 'MANPAGER=cat MANWIDTH='.(&columns/2-4).' man {}']}))
]]

  -- Tags
  map("n", "<Leader>t", ":Tags<CR>", { silent = true })
  map("n", "<A-t>", ":BTags<CR>", { silent = true })

  map("i", "<C-x><C-z>", "<Plug>(fzf-complete-line)", { noremap = false })

  -- Word completion popup
  cmd [[
    inoremap <expr> <C-x><C-w> fzf#vim#complete#word({
      \ 'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})
  ]]

  -- Word completion window
  cmd [[
    inoremap <expr> <C-x><C-a> fzf#vim#complete({
      \ 'source':  'cat /usr/share/dict/words',
      \ 'options': '--multi --reverse --margin 15%,0',
      \ 'left':    20})
  ]]

  -- Clipboard manager
  cmd [[
    inoremap <expr> <a-.> fzf#vim#complete({
      \ 'source': 'copyq eval -- "tab(\"&clipboard\"); for(i=size(); i>0; --i) print(str(read(i-1)) + \"\n\");" \| tac',
      \ 'options': '--no-border',
      \ 'reducer': { line -> substitute(line[0], '^ *[0-9]\+ ', '', '') },
      \ 'window': 'call FloatingFZF()'})
  ]]

  cmd [[
    inoremap <expr> <a-;> fzf#complete({
        \ 'source': 'greenclip print 2>/dev/null \| grep -v "^\s*$" \| nl -w2 -s" "',
        \ 'options': '--no-border',
        \ 'reducer': { line -> substitute(line[0], '^ *[0-9]\+ ', '', '') },
        \ 'window': 'call FloatingFZF()'})
  ]]

  -- Floating window
  cmd [[
    function! s:create_float(hl, opts)
      let buf = nvim_create_buf(v:false, v:true)
      let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
      let win = nvim_open_win(buf, v:true, opts)
      call setwinvar(win, '&winhighlight', 'NormalFloat:'.a:hl)
      call setwinvar(win, '&colorcolumn', '')
      return buf
    endfunction

    function! FloatingFZF()
      " Size and position
      let width = float2nr(&columns * 0.9)
      let height = float2nr(&lines * 0.6)
      let row = float2nr((&lines - height) / 2)
      let col = float2nr((&columns - width) / 2)

      " Border
      let top = '┏━' . repeat('─', width - 4) . '━┓'
      let mid = '│'  . repeat(' ', width - 2) .  '│'
      let bot = '┗━' . repeat('─', width - 4) . '━┛'
      let border = [top] + repeat([mid], height - 2) + [bot]

      " Draw frame
      let s:frame = s:create_float('Comment',
        \ {'row': row, 'col': col, 'width': width, 'height': height})
      call nvim_buf_set_lines(s:frame, 0, -1, v:true, border)

      " Draw viewport
      call s:create_float('Normal',
        \ {'row': row + 1, 'col': col + 2, 'width': width - 4, 'height': height - 2})

      augroup fzf_floating
        au!
        au BufWipeout <buffer> execute 'bwipeout' s:frame
      augroup END
    endfunction
  ]]

  -- Fzf wrapper
  cmd [[
        function! FzfWrapper(opts) abort
            let opts = a:opts
            let options = ''
            if has_key(opts, 'options')
                let options = type(opts.options) == v:t_list ? join(opts.options) : opts.options
            endif
            if options !~ '--expect' && has_key(opts, 'sink*')
                let Sink = remove(opts, 'sink*')
                let wrapped = fzf#wrap(opts)
                let wrapped['sink*'] = Sink
            else
                let wrapped = fzf#wrap(opts)
            endif
            call fzf#run(wrapped)
        endfunction

        aug Fzf
            au!
            au FileType fzf lua require('plugs.fzf').prepare_ft()
            au VimResized * lua pcall(require('plugs.fzf').resize_preview_layout)

            " This lazy-loads fzf
            au FuncUndefined fzf#* lua require('plugs.fzf')
            au CmdUndefined FZF,BCommits,History,GFiles,Marks,Buffers,Rg lua require('plugs.fzf')
        aug END

        sil! au! fzf_buffers *
        sil! aug! fzf_buffers
    ]]

  map("n", "<Leader>f;", [[<Cmd>:History:<CR>]])
  map(
      "n", "<Leader>fc",
      [[:lua require('common.gittool').root_exe('BCommits')<CR>]]
  )
  map(
      "n", "<Leader>fg",
      [[:lua require('common.gittool').root_exe('GFiles')<CR>]]
  )
  map(
      "n", "<Leader>ff",
      [[:lua require('common.gittool').root_exe(require('plugs.fzf').files)<CR>]]
  )

  map("n", "<Leader>f,", [[:lua require('common.gittool').root_exe('Rg')<CR>]])

  map("n", "<C-f>", ":Rg<CR>")

  -- Change directory to buffers dir
  map("n", "<Leader>cd", ":lcd %:p:h<CR>")
  map("n", "<Leader>lo", ":Locate .<CR>")

  map("n", "<Leader>A", ":Windows<CR>", { silent = true })
  map("n", "<LocalLeader>r", ":RG<CR>")
  map("n", "<A-f>", ":Files<CR>", { silent = true })
  -- map("n", "<Leader>gf", ":GFiles<CR>", { silent = true })
  map("n", "<Leader>hf", ":History<CR>", { silent = true })

  map("n", "<Leader>ls", ":LS<CR>", { silent = true })
  -- map("n", "<Leader>cm", ":Commands<CR>", { silent = true })
  -- map("n", "<Leader>ht", ":Helptags<CR>", { silent = true })

  map("n", "<C-l>m", "<Plug>(fzf-maps-n)", { noremap = false })
  map("x", "<C-l>m", "<Plug>(fzf-maps-x)", { noremap = false })
  map("i", "<C-l>m", "<Plug>(fzf-maps-i)", { noremap = false })
  map("o", "<C-l>m", "<Plug>(fzf-maps-o)", { noremap = false })

  M.resize_preview_layout()
end

init()

return M
