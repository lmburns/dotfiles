local M = {}

local kutils = require("common.kutils")
local utils = require("common.utils")
local map = utils.map
local t = utils.t
local autocmd = utils.autocmd

-- function! s:show_documentation()
--   if (index(['vim','help'], &filetype) >= 0)
--     execute 'h '.expand('<cword>')
--   elseif (coc#rpc#ready())
--     call CocActionAsync('doHover')
--   else
--     execute '!' . &keywordprg . " " . expand('<cword>')
--   endif
-- endfunction

function M.go2def()
  local cur_bufnr = api.nvim_get_current_buf()
  local by
  if vim.bo.ft == "help" then
    api.nvim_feedkeys(utils.termcodes["<C-]>"], "n", false)
    by = "tag"
  else
    local err, res = M.a2sync("jumpDefinition", { "drop" })
    if not err then
      by = "coc"
    elseif res == "timeout" then
      vim.notify("Go to reference Timeout", vim.log.levels.WARN)
    else
      local cword = fn.expand("<cword>")
      if not pcall(
          function()
            local wv = fn.winsaveview()
            cmd("ltag " .. cword)
            local def_size = fn.getloclist(0, { size = 0 }).size
            by = "ltag"
            if def_size > 1 then
              api.nvim_set_current_buf(cur_bufnr)
              fn.winrestview(wv)
              cmd("abo lw")
            elseif def_size == 1 then
              cmd("lcl")
              fn.search(cword, "cs")
            end
          end
      ) then
        fn.searchdecl(cword)
        by = "search"
      end
    end
  end
  if api.nvim_get_current_buf() ~= cur_bufnr then
    cmd("norm! zz")
  end

  if by then
    kutils.cool_echo("go2def: " .. by, "Special")
  end
end

-- Use K to show documentation in preview window
function M.show_documentation()
  local ft = vim.bo.ft
  if ft == "help" or ft == "vim" then
    cmd(("sil! h %s"):format(fn.expand("<cword>")))
  elseif fn["coc#rpc#ready"]() then
    -- definitionHover -- doHover
    local err, res = M.a2sync("definitionHover")
    if err then
      if res == "timeout" then
        vim.notify("Show documentation Timeout", vim.log.levels.WARN)
      end
      cmd("norm! K")
    end
  else
    cmd("!" .. o.keywordprg .. " " .. fn.expand("<cword>"))
  end
end

-- CocActionAsync
function M.a2sync(action, args, time)
  local done = false
  local err = false
  local res = ""
  args = args or {}
  table.insert(
      args, function(e, r)
        if e ~= vim.NIL then
          err = true
        end
        if r ~= vim.NIL then
          res = r
        end
        done = true
      end
  )
  fn.CocActionAsync(action, unpack(args))
  local wait_ret = vim.wait(time or 1000, function() return done end)
  err = err or not wait_ret
  if not wait_ret then
    res = "timeout"
  end
  return err, res
end

-- Code actions
function M.code_action(mode, only)
  if type(mode) == "string" then
    mode = { mode }
  end
  local no_actions = true
  for _, m in ipairs(mode) do
    local err, ret = M.a2sync("codeActions", { m, only }, 1000)
    if err then
      if ret == "timeout" then
        vim.notify("codeAction timeout", vim.log.levels.WARN)
        break
      end
    else
      if type(ret) == "table" and #ret > 0 then
        fn.CocActionAsync("codeAction", m, only)
        no_actions = false
        break
      end
    end
  end
  if no_actions then
    vim.notify("No code Action available", vim.log.levels.WARN)
  end
end

-- Jump to location list
function M.jump2loc(locs, skip)
  locs = locs or vim.g.coc_jump_locations
  fn.setloclist(0, {}, " ", { title = "CocLocationList", items = locs })
  if not skip then
    local winid = fn.getloclist(0, { winid = 0 }).winid
    if winid == 0 then
      cmd("abo lw")
    else
      api.nvim_set_current_win(winid)
    end
  end
end

-- Accept the completion
function M.accept_complete()
  local mode = api.nvim_get_mode().mode
  if mode == "i" then
    return kutils.termcodes["<C-l>"]
  elseif mode == "ic" then
    local ei_bak = vim.o.ei
    vim.o.ei = "CompleteDone"
    vim.schedule(
        function()
          vim.o.ei = ei_bak
          fn.CocActionAsync("stopCompletion")
        end
    )
    return kutils.termcodes["<C-y>"]
  else
    return kutils.termcodes["<Ignore>"]
  end
end

-- Coc rename
function M.rename()
  vim.g.coc_jump_locations = nil
  fn.CocActionAsync(
      "rename", "", function(err, res)
        if err == vim.NIL and res then
          local loc = vim.g.coc_jump_locations
          if loc then
            local uri = vim.uri_from_bufnr(0)
            local dont_open = true
            for _, lo in ipairs(loc) do
              if lo.uri ~= uri then
                dont_open = false
                break
              end
            end
            M.jump2loc(loc, dont_open)
          end
        end
      end
  )
end

function M.diagnostic_change()
  if vim.v.exiting == vim.NIL then
    local info = fn.getqflist({ id = diag_qfid, winid = 0, nr = 0 })
    if info.id == diag_qfid and info.winid ~= 0 then
      M.diagnostic(info.winid, info.nr, true)
    end
  end
end

function M.diagnostic(winid, nr, keep)
  fn.CocActionAsync(
      "diagnosticList", "", function(err, res)
        if err == vim.NIL then
          local items = {}
          for _, d in ipairs(res) do
            local text = ("[%s%s] %s"):format(
                (d.source == "" and "coc.nvim" or d.source),
                (d.code == vim.NIL and "" or " " .. d.code),
                d.message:match("([^\n]+)\n*")
            )
            local item = {
              filename = d.file,
              lnum = d.lnum,
              end_lnum = d.end_lnum,
              col = d.col,
              end_col = d.end_col,
              text = text,
              type = d.severity,
            }
            table.insert(items, item)
          end
          local id
          if winid and nr then
            id = diag_qfid
          else
            local info = fn.getqflist({ id = diag_qfid, winid = 0, nr = 0 })
            id, winid, nr = info.id, info.winid, info.nr
          end
          local action = id == 0 and " " or "r"
          fn.setqflist(
              {}, action, {
                id = id ~= 0 and id or nil,
                title = "CocDiagnosticList",
                items = items,
              }
          )

          if id == 0 then
            local info = fn.getqflist({ id = id, nr = 0 })
            diag_qfid, nr = info.id, info.nr
          end

          if not keep then
            if winid == 0 then
              cmd("bo cope")
            else
              api.nvim_set_current_win(winid)
            end
            cmd(("sil %dchi"):format(nr))
          end
        end
      end
  )
end

M.hl_fallback = (function()
  local fb_bl_ft = {
    "qf",
    "fzf",
    "vim",
    "sh",
    "python",
    "go",
    "c",
    "cpp",
    "rust",
    "java",
    "lua",
    "typescript",
    "javascript",
    "css",
    "html",
    "xml",
  }
  local hl_fb_tbl = {}
  local re_s, re_e = vim.regex([[\k*$]]), vim.regex([[^\k*]])
  local function cur_word_pat()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]:match("%C*")
    local _, e_off = re_e:match_str(line:sub(col + 1, -1))
    local pat = ""
    if e_off ~= 0 then
      local s, e = re_s:match_str(line:sub(1, col + 1))
      local word = line:sub(s + 1, e + e_off - 1)
      pat = ([[\<%s\>]]):format(word:gsub("[\\/~]", [[\%1]]))
    end
    return pat
  end

  return function()
    local ft = vim.bo.ft
    if vim.tbl_contains(fb_bl_ft, ft) or api.nvim_get_mode().mode == "t" then
      return
    end

    local m_id, winid = unpack(hl_fb_tbl)
    pcall(fn.matchdelete, m_id, winid)

    winid = api.nvim_get_current_win()
    m_id = fn.matchadd(
        "CocHighlightText", cur_word_pat(), -1, -1, { window = winid }
    )
    hl_fb_tbl = { m_id, winid }
  end
end)()

function M.post_open_float()
  local winid = vim.g.coc_last_float_win
  if winid and api.nvim_win_is_valid(winid) then
    local bufnr = api.nvim_win_get_buf(winid)
    api.nvim_buf_call(bufnr, function() vim.wo[winid].showbreak = "NONE" end)
  end
end

function _G.check_backspace()
  -- local col = fn.col(".") - 1
  -- return col or (fn.getline(".")[col - 1]):match([[\s]])

  local col = api.nvim_win_get_cursor(0)[2]
  return (col == 0 or api.nvim_get_current_line():sub(col, col):match("%s")) and
             true
end

function M.did_init(silent)
  if vim.g.coc_service_initialized == 0 then
    if silent then
      vim.notify([[coc.nvim hasn't initialized]], vim.log.levels.WARN)
    end
    return false
  end
  return true
end

function M.skip_snippet()
  fn.CocActionAsync("snippetNext")
  return utils.termcodes["<BS>"]
end

-- UNUSED

function M.scroll(down)
  if #fn["coc#float#get_float_win_list"]() > 0 then
    return fn["coc#float#scroll"](down)
  else
    return down and utils.termcodes["<C-f>"] or utils.termcodes["<C-b>"]
  end
end

function M.scroll_insert(right)
  if #fn["coc#float#get_float_win_list"]() > 0 and fn.pumvisible() == 0 and
      api.nvim_get_current_win() ~= vim.g.coc_last_float_win then
    return fn["coc#float#scroll"](right)
  else
    return right and utils.termcodes["<Right>"] or utils.termcodes["<Left>"]
  end
end

-- ========================== Init ==========================

function M.init()
  -- g.coc_global_extensions = {
  --   "coc-snippets",
  --   "coc-diagnostic",
  --   "coc-yank",
  --   "coc-marketplace",
  --   "coc-tabnine",
  --   "coc-tag",
  --   "coc-html",
  --   "coc-css",
  --   "coc-json",
  --   "coc-yaml",
  --   "coc-pyright",
  --   "coc-vimtex",
  --   "coc-vimlsp",
  --   "coc-sh",
  --   "coc-sql",
  --   "coc-xml",
  --   "coc-fzf-preview",
  --   "coc-syntax",
  --   "coc-git",
  --   "coc-go",
  --   "coc-clangd",
  --   "coc-rls",
  --   "coc-rust-analyzer",
  --   "coc-toml",
  --   "coc-solargraph",
  --   "coc-prettier",
  --   "coc-r-lsp",
  --   "coc-perl",
  --   "coc-tsserver",
  --   "coc-zig",
  --   "coc-dlang",
  --   "coc-lua",
  -- }

  -- 'coc-pairs',
  --
  -- 'coc-sumneko-lua',
  -- 'coc-clojure',
  -- 'coc-nginx',
  -- 'coc-toml',
  -- 'coc-explorer'

  -- g.coc_enable_locationlist = 0
  -- g.coc_selectmode_mapping = 0

  diag_qfid = -1

  fn["coc#config"](
      "languageserver.lua.settings.Lua.workspace",
      { library = { [vim.env.VIMRUNTIME .. "/lua"] = true } }
  )

  g.coc_fzf_opts = { "--no-border", "--layout=reverse-list" }

  -- Disable CocFzfList
  vim.schedule(function() cmd("au! CocFzfLocation User CocLocationsChange") end)

  -- [[CursorHold * silent call CocActionAsync('highlight')]],
  autocmd(
      "Coc", {
        [[User CocLocationsChange ++nested lua require('plugs.coc').jump2loc()]],
        [[User CocDiagnosticChange ++nested lua require('plugs.coc').diagnostic_change()]],
        [[FileType rust,scala,python,ruby,perl,lua,c,cpp,zig,d,javascript,typescript nmap <silent> <c-]> <Plug>(coc-definition)]],
        [[CursorHold * sil! call CocActionAsync('highlight', '', v:lua.require('plugs.coc').hl_fallback)]],
        [[FileType typescript,json setl formatexpr=CocActionAsync('formatSelected')]],
        [[User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')]],
        [[FileType list lua vim.cmd('pa nvim-bqf') require('bqf.magicwin.handler').attach()]],
        [[VimLeavePre * if get(g:, 'coc_process_pid', 0) | call system('kill -9 -- -' . g:coc_process_pid) | endif]],
        [[FileType log :let b:coc_enabled = 0]],
        [[User CocOpenFloat lua require('plugs.coc').post_open_float()]],
      }, true
  )

  cmd [[command! -nargs=0 CocMarket :CocFzfList marketplace]]
  cmd [[command! -nargs=0 Prettier :CocCommand prettier.formatFile]]
  -- use `:Format` to format current buffer
  cmd [[command! -nargs=0 Format :call CocAction('format')]]
  -- use `:Fold` to fold current buffer
  cmd [[command! -nargs=? Fold :call CocAction('fold', <f-args>)]]
  -- use `:OR` for organize import of current buffer
  cmd [[command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')]]
  cmd [[command! -nargs=0 CocOutput CocCommand workspace.showOutput]]

  map("n", "<LocalLeader>s", ":CocFzfList symbols<CR>")
  -- map("n", "<A-c>", ":CocFzfList commands<CR>")
  map("n", "<A-'>", ":CocFzfList yank<CR>", { silent = true })
  map("n", "<C-x><C-l>", ":CocFzfList<CR>")
  -- map("n", "<C-x><C-r>", ":CocCommand fzf-preview.CocReferences<CR>")
  map("n", "<C-x><C-d>", ":CocCommand fzf-preview.CocTypeDefinition<CR>")
  map("n", "<C-x><C-]>", ":CocCommand fzf-preview.CocImplementations<CR>")
  map("n", "<C-x><C-h>", ":CocCommand fzf-preview.CocImplementations<CR>")

  map("n", "<A-[>", ":CocCommand fzf-preview.VistaCtags<CR>")
  map("n", "<LocalLeader>t", ":CocCommand fzf-preview.BufferTags<CR>")

  -- map("n", "<C-x><C-r>", ":Telescope coc references<CR>")
  -- map("n", "<C-x><C-[>", ":Telescope coc definitions<CR>")
  -- map("n", "<C-x><C-]>", ":Telescope coc implementations<CR>")
  -- map("n", "<C-x><C-r>", ":Telescope coc diagnostics<CR>")

  -- Use `[g` and `]g` to navigate diagnostics
  -- map("n", "[g", "<Plug>(coc-diagnostic-prev)", { noremap = false })
  -- map("n", "]g", "<Plug>(coc-diagnostic-next)", { noremap = false })
  map("n", "[g", ":call CocAction('diagnosticPrevious')<CR>", { silent = true })
  map("n", "]g", ":call CocAction('diagnosticNext')<CR>", { silent = true })
  map(
      "n", "<Leader>?", ":call CocAction('diagnosticInfo')<CR>",
      { silent = true }
  )

  -- Goto code navigation
  map("n", "gd", [[:lua require('plugs.coc').go2def()<CR>]])
  map("n", "gy", [[<Cmd>call CocActionAsync('jumpTypeDefinition', 'drop')<CR>]])
  map("n", "gi", [[<Cmd>call CocActionAsync('jumpImplementation', 'drop')<CR>]])
  map("n", "gr", [[<Cmd>call CocActionAsync('jumpUsed', 'drop')<CR>]])

  -- map("n", "gd", "<Plug>(coc-definition)", { noremap = false, silent = true })
  -- map(
  --     "n", "gy", "<Plug>(coc-type-definition)",
  --     { noremap = false, silent = true }
  -- )
  -- map(
  --     "n", "gi", "<Plug>(coc-implementation)",
  --     { noremap = false, silent = true }
  -- )
  -- map("n", "gr", "<Plug>(coc-references)", { noremap = false, silent = true })

  -- Remap for rename current word
  -- map("n", "<Leader>rn", "<Plug>(coc-rename)", { noremap = false })
  map("n", "<Leader>rn", [[<Cmd>lua require('plugs.coc').rename()<CR>]])

  map("x", "<Leader>fm", "<Plug>(coc-format-selected)", { noremap = false })
  map("n", "<Leader>fm", "<Plug>(coc-format-selected)", { noremap = false })

  -- Fix autofix problem of current line
  map("n", "<Leader>qf", "<Plug>(coc-fix-current)", { noremap = false })

  -- Create mappings for function text object
  map("x", "if", "<Plug>(coc-funcobj-i)", { noremap = false })
  map("x", "af", "<Plug>(coc-funcobj-a)", { noremap = false })
  map("o", "if", "<Plug>(coc-funcobj-i)", { noremap = false })
  map("o", "af", "<Plug>(coc-funcobj-a)", { noremap = false })

  -- map("n", "{g", "<Plug>(coc-git-prevchunk)")
  -- map("n", "}g", "<Plug>(coc-git-nextchunk)")

  -- Navigate conflicts of current buffer
  map("n", "[c", "<Plug>(coc-git-prevconflict)", { noremap = false })
  map("n", "]c", "<Plug>(coc-git-nextconflict)", { noremap = false })

  -- Show chunk diff at current position
  map("n", "gs", "<Plug>(coc-git-chunkinfo)", { noremap = false })
  -- Show commit contains current position
  map("n", "gC", "<Plug>(coc-git-commit)", { noremap = false })

  map(
      "n", "<Leader><Leader>o", "<Plug>(coc-openlink)",
      { noremap = true, silent = true }
  )
  map(
      "n", "<Leader><Leader>l", "<Plug>(coc-codelens-action)",
      { noremap = true, silent = true }
  )

  -- Show completions
  map("n", "K", [[:silent lua require('plugs.coc').show_documentation()<CR>]])

  -- Refresh coc completions
  map("i", "<A-r>", "coc#refresh()", { expr = true, silent = true })

  -- CodeActions
  map("n", "<Leader>ac", [[:lua require('plugs.coc').code_action('')<CR>]])
  map(
      "n", "<A-CR>",
      [[:lua require('plugs.coc').code_action({'cursor', 'line'})<CR>]]
  )
  map(
      "x", "<A-CR>",
      [[:<C-u>lua require('plugs.coc').code_action(vim.fn.visualmode())<CR>]]
  )

  -- TODO: Use more!
  -- Remap for do codeAction of current line
  map("n", "<Leader>wc", "<Plug>(coc-codeaction)", { noremap = false })
  map("x", "<Leader>w", "<Plug>(coc-codeaction-selected)", { noremap = false })
  map("n", "<Leader>ww", "<Plug>(coc-codeaction-selected)", { noremap = false })

  -- Popup
  map(
      "i", "<Tab>", [[pumvisible() ? coc#_select_confirm() : "\<C-g>u\<tab>"]],
      { expr = true, silent = true }
  )

  -- map(
  --     "i", "<Tab>",
  --     [[pumvisible() ? "\<C-n>" : v:lua.check_back_space() ? "\<TAB>" : coc#refresh()]],
  --     { silent = true, expr = true }
  -- )

  map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<C-h>"]], { expr = true })

  -- map("i", "<CR>", [[pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"]], { expr = true })

  -- g.endwise_no_mappings = true
  -- map(
  --     "i", "<Plug>CustomCocCR", [[\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>]],
  --     { noremap = true }
  -- )
  -- map("i", "<CR>", "<Plug>CustomCocCR<Plug>DiscretionaryEnd", { noremap = true })

  -- Git
  map(
      "n", "<LocalLeader>gg", ":CocCommand fzf-preview.GitActions<CR>",
      { silent = true }
  )
  map(
      "n", "<LocalLeader>gs", ":CocCommand fzf-preview.GitStatus<CR>",
      { silent = true }
  )
  map(
      "n", "<LocalLeader>gr", ":CocCommand fzf-preview.GitLogs<CR>",
      { silent = true }
  )
  map(
      "n", "<LocalLeader>gp", ":<C-u>CocList --normal gstatus<CR>",
      { silent = true }
  )

  -- Git
  map("n", "<Leader>gD", ":CocCommand git.diffCached<CR>", { silent = true })
  map("n", "<Leader>gu", ":<C-u>CocCommand git.chunkUndo<CR>", { silent = true })
  map("n", ",ga", ":<C-u>CocCommand git.chunkStage<CR>", { silent = true })
  map(
      "n", "<Leader>gF", ":<C-u>CocCommand git.foldUnchanged<CR>",
      { silent = true }
  )
  map(
      "n", "<Leader>go", ":<C-u>CocCommand git.browserOpen<CR>",
      { silent = true }
  )
  map("n", "<Leader>gla", ":<C-u>CocFzfList commits<cr>", { silent = true })
  map("n", "<Leader>glc", ":<C-u>CocFzfList bcommits<cr>", { silent = true })
  map(
      "n", "<Leader>gll", "<Plug>(coc-git-commit)",
      { noremap = true, silent = true }
  )

  -- Snippet
  -- map(
  --     "i", "<C-]>", [[!get(b:, 'coc_snippet_active') ? "\<C-]>" : "\<C-j>"]],
  --     { expr = true }
  -- )
  -- map(
  --     "s", "<C-]>", [[v:lua.require'plugs.coc'.skip_snippet()]],
  --     { noremap = true, expr = true }
  -- )

  -- map("n", ";ff", ":Format<CR>")

  map(
      "n", "<Leader>ab", ":CocCommand fzf-preview.AllBuffers<CR>",
      { silent = true }
  )
  map("n", "<Leader>C", ":CocCommand fzf-preview.Changes<CR>", { silent = true })
  map(
      "n", "<LocalLeader>;", ":CocCommand fzf-preview.Lines<CR>",
      { silent = true }
  )

  map(
      "n", "<LocalLeader>d", ":CocCommand fzf-preview.ProjectFiles<CR>",
      { silent = true }
  )
  map(
      "n", "<LocalLeader>g", ":CocCommand fzf-preview.GitFiles<CR>",
      { silent = true }
  )

  map("n", "<Leader>se", ":CocFzfList snippets<CR>", { silent = true })
  map("n", "<M-/>", ":CocCommand fzf-preview.Marks<CR>", { silent = true })
end

return M
