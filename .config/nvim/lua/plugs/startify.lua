local utils = require("common.utils")
local map = utils.map

g.webdevicons_enable_startify = 1
g.startify_files_number = 5
g.startify_change_to_dir = 1
g.startify_custom_header = {}
g.startify_relative_path = 1
g.startify_use_env = 1
g.startify_update_oldfiles = 1
g.startify_session_sort = 1
g.startify_session_delete_buffers = 1
g.startify_fortune_use_unicode = 1
g.startify_padding_left = 3
g.startify_session_remove_lines = { "setlocal", "winheight" }

g.startify_session_dir = fn.fnamemodify(fn.stdpath("data"), ":p") .. "sessions"

g.startify_commands = { { ["1"] = "CocList" }, { ["2"] = "terminal" } }

cmd [[
  function! s:gitModified()
    let files = systemlist('git ls-files -m 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
  endfunction

  " same as above, but show untracked files, honouring .gitignore
  function! s:gitTracked()
    let files = systemlist('git --exclude-standard 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
  endfunction

  function! s:explore()
    sleep 350m
    call execute('CocCommand explorer')
  endfunction

  function! StartifyEntryFormat()
    return 'WebDevIconsGetFileTypeSymbol(absolute_path) ." ". entry_path'
  endfunction

  " Custom startup list, only show MRU from current directory/project
  let g:startify_lists = [
  \  { 'type': 'bookmarks', 'header': [ " \uf5c2 Bookmarks" ]      },
  \  { 'type': 'commands',  'header': [ " \ufb32 Commands" ]       },
  \  { 'type': 'files',     'header': [ " \ufa1eMRU"] },
  \  { 'type': 'dir',       'header': [ " \ufa1eFiles ". getcwd() ] },
  \  { 'type':  function('s:gitModified'),  'header': ['git modified']},
  \  { 'type':  function('s:gitTracked'), 'header': ['git untracked']},
  \  { 'type': 'sessions',  'header': [ " \ue62e Sessions" ]       }
  \ ]
]]

g.startify_commands = {
  { up = { "Packer Compile", ":PackerCompile" } },
  { ug = { "Upgrade Plugins", ":PackerSync" } },
  { uc = { "Update CoC Plugins", ":CocUpdate" } },
  { vd = { "Make Wiki Entry", ":VimwikiMakeDiaryNote" } },
}

g.startify_bookmarks = {
  { co = "~/.config/nvim/init.lua" },
  { pl = "~/.config/nvim/lua/plugins.lua" },
  { lc = "~/.config/lf/lfrc" },
  { zs = "~/.config/zsh/.zshrc" },
  { za = "~/.config/zsh/zsh.d/aliases.zsh" },
  { vi = "~/vimwiki/index.md" },
  { vib = "~/vimwiki/scripting/index.md" },
}

map("n", "<Leader>st", ":Startify<CR>")
