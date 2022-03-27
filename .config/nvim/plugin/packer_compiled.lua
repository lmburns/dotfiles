-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["HighStr.nvim"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins-d/HighStr\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/HighStr.nvim",
    url = "https://github.com/Pocco81/HighStr.nvim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewOpen", "DiffviewFileHistory" },
    config = { "\27LJ\2\nA\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\vconfig\23plugins-d/diffview\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\nA\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\vconfig\23plugins-d/gitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim",
    wants = { "plenary.nvim" }
  },
  ["goyo.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/goyo.vim",
    url = "https://github.com/junegunn/goyo.vim"
  },
  indentline = {
    config = { 'require("plugins-d/indentline")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/indentline",
    url = "https://github.com/yggdroot/indentline"
  },
  kimbox = {
    after = { "lualine.nvim", "telescope.nvim" },
    loaded = true,
    only_config = true
  },
  ["limelight.vim"] = {
    config = { 'require("plugins-d/limelight")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/limelight.vim",
    url = "https://github.com/junegunn/limelight.vim"
  },
  ["lualine.nvim"] = {
    config = { 'require("plugins-d/lualine")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  neogit = {
    config = { "\27LJ\2\n?\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\vconfig\21plugins-d/neogit\frequire\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/neogit",
    url = "https://github.com/TimUntersberger/neogit"
  },
  nerdcommenter = {
    config = { 'require("plugins-d/nerdcommenter")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nerdcommenter",
    url = "https://github.com/preservim/nerdcommenter"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24plugins-d/colorizer\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-gps"] = {
    config = { 'require("nvim-gps").setup()' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-gps",
    url = "https://github.com/SmiteshP/nvim-gps"
  },
  ["nvim-neoclip.lua"] = {
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27plugins-d/nvim-neoclip\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-neoclip.lua",
    url = "https://github.com/AckslD/nvim-neoclip.lua"
  },
  ["nvim-tree-docs"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-tree-docs",
    url = "https://github.com/nvim-treesitter/nvim-tree-docs"
  },
  ["nvim-treesitter"] = {
    after = { "nvim-gps", "nvim-ts-rainbow", "nvim-treesitter-refactor", "nvim-treesitter-textobjects", "nvim-tree-docs" },
    loaded = true,
    only_config = true
  },
  ["nvim-treesitter-refactor"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-refactor",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-refactor"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-rainbow"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-ts-rainbow",
    url = "https://github.com/p00f/nvim-ts-rainbow"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    commands = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  ["sqlite.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sqlite.lua",
    url = "https://github.com/tami5/sqlite.lua"
  },
  ["substitute.nvim"] = {
    config = { 'require("plugins-d/substitute")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/substitute.nvim",
    url = "https://github.com/gbprod/substitute.nvim"
  },
  ["telescope-bookmarks.nvim"] = {
    config = { "\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14bookmarks\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-bookmarks.nvim",
    url = "https://github.com/dhruvmanila/telescope-bookmarks.nvim"
  },
  ["telescope-coc.nvim"] = {
    config = { "\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bcoc\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-coc.nvim",
    url = "https://github.com/fannheyward/telescope-coc.nvim"
  },
  ["telescope-frecency.nvim"] = {
    config = { "\27LJ\2\nM\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\rfrecency\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-frecency.nvim",
    url = "https://github.com/nvim-telescope/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    config = { "\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bfzf\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-ghq.nvim"] = {
    config = { "\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bghq\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ghq.nvim",
    url = "https://github.com/nvim-telescope/telescope-ghq.nvim"
  },
  ["telescope-github.nvim"] = {
    config = { "\27LJ\2\nG\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\agh\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-github.nvim",
    url = "https://github.com/nvim-telescope/telescope-github.nvim"
  },
  ["telescope-ultisnips.nvim"] = {
    config = { "\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ultisnips\19load_extension\14telescope\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ultisnips.nvim",
    url = "https://github.com/fhill2/telescope-ultisnips.nvim"
  },
  ["telescope.nvim"] = {
    after = { "telescope-github.nvim", "telescope-ultisnips.nvim", "nvim-neoclip.lua", "telescope-coc.nvim", "telescope-frecency.nvim", "telescope-fzf-native.nvim", "telescope-bookmarks.nvim", "telescope-ghq.nvim" },
    config = { "require('plugins-d/telescope')" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["todo-comments.nvim"] = {
    config = { "\27LJ\2\n7\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\28plugins-d/todo-comments\frequire\0" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/todo-comments.nvim",
    url = "https://github.com/folke/todo-comments.nvim",
    wants = { "plenary.nvim" }
  },
  undotree = {
    commands = { "UndoTreeToggle" },
    config = { 'require("plugins-d/undotree")' },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-devicons",
    url = "https://github.com/ryanoasis/vim-devicons"
  },
  ["vim-easy-align"] = {
    config = { "\27LJ\2\n\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0*/vimscript/plugins/vim-easy-align.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-easy-align",
    url = "https://github.com/junegunn/vim-easy-align"
  },
  ["vim-endwise"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-endwise",
    url = "https://github.com/tpope/vim-endwise"
  },
  ["vim-gutentags"] = {
    config = { "\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-gutentags.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-gutentags",
    url = "https://github.com/ludovicchabant/vim-gutentags"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-sandwich"] = {
    config = { "\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-sandwhich.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-sandwich",
    url = "https://github.com/machakann/vim-sandwich"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  vimtex = {
    config = { 'require("plugins-d/vimtex")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vimtex",
    url = "https://github.com/lervag/vimtex"
  },
  ["vista.vim"] = {
    config = { 'require("plugins-d/vista")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vista.vim",
    url = "https://github.com/liuchengxu/vista.vim"
  },
  ["vizunicode.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vizunicode.vim",
    url = "https://github.com/wfxr/vizunicode.vim",
    wants = { "vim-devicons" }
  }
}

time([[Defining packer_plugins]], false)
local module_lazy_loads = {
  ["^neogit"] = "neogit"
}
local lazy_load_called = {['packer.load'] = true}
local function lazy_load_module(module_name)
  local to_load = {}
  if lazy_load_called[module_name] then return nil end
  lazy_load_called[module_name] = true
  for module_pat, plugin_name in pairs(module_lazy_loads) do
    if not _G.packer_plugins[plugin_name].loaded and string.match(module_name, module_pat) then
      to_load[#to_load + 1] = plugin_name
    end
  end

  if #to_load > 0 then
    require('packer.load')(to_load, {module = module_name}, _G.packer_plugins)
    local loaded_mod = package.loaded[module_name]
    if loaded_mod then
      return function(modname) return loaded_mod end
    end
  end
end

if not vim.g.packer_custom_loader_enabled then
  table.insert(package.loaders, 1, lazy_load_module)
  vim.g.packer_custom_loader_enabled = true
end

-- Config for: vim-gutentags
time([[Config for vim-gutentags]], true)
try_loadstring("\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-gutentags.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-gutentags")
time([[Config for vim-gutentags]], false)
-- Config for: limelight.vim
time([[Config for limelight.vim]], true)
require("plugins-d/limelight")
time([[Config for limelight.vim]], false)
-- Config for: vista.vim
time([[Config for vista.vim]], true)
require("plugins-d/vista")
time([[Config for vista.vim]], false)
-- Config for: nerdcommenter
time([[Config for nerdcommenter]], true)
require("plugins-d/nerdcommenter")
time([[Config for nerdcommenter]], false)
-- Config for: vim-sandwich
time([[Config for vim-sandwich]], true)
try_loadstring("\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-sandwhich.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-sandwich")
time([[Config for vim-sandwich]], false)
-- Config for: kimbox
time([[Config for kimbox]], true)
require("plugins-d/kimbox")
time([[Config for kimbox]], false)
-- Config for: vim-easy-align
time([[Config for vim-easy-align]], true)
try_loadstring("\27LJ\2\n\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0*/vimscript/plugins/vim-easy-align.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-easy-align")
time([[Config for vim-easy-align]], false)
-- Config for: substitute.nvim
time([[Config for substitute.nvim]], true)
require("plugins-d/substitute")
time([[Config for substitute.nvim]], false)
-- Config for: indentline
time([[Config for indentline]], true)
require("plugins-d/indentline")
time([[Config for indentline]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n5\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\26plugins-d/tree-sitter\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: todo-comments.nvim
time([[Config for todo-comments.nvim]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\28plugins-d/todo-comments\frequire\0", "config", "todo-comments.nvim")
time([[Config for todo-comments.nvim]], false)
-- Config for: vimtex
time([[Config for vimtex]], true)
require("plugins-d/vimtex")
time([[Config for vimtex]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd lualine.nvim ]]

-- Config for: lualine.nvim
require("plugins-d/lualine")

vim.cmd [[ packadd nvim-tree-docs ]]
vim.cmd [[ packadd nvim-treesitter-textobjects ]]
vim.cmd [[ packadd nvim-gps ]]

-- Config for: nvim-gps
require("nvim-gps").setup()

vim.cmd [[ packadd nvim-treesitter-refactor ]]
vim.cmd [[ packadd nvim-ts-rainbow ]]
vim.cmd [[ packadd sqlite.lua ]]
vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd popup.nvim ]]
vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
require('plugins-d/telescope')

vim.cmd [[ packadd telescope-ghq.nvim ]]

-- Config for: telescope-ghq.nvim
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bghq\19load_extension\14telescope\frequire\0", "config", "telescope-ghq.nvim")

vim.cmd [[ packadd telescope-ultisnips.nvim ]]

-- Config for: telescope-ultisnips.nvim
try_loadstring("\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ultisnips\19load_extension\14telescope\frequire\0", "config", "telescope-ultisnips.nvim")

vim.cmd [[ packadd telescope-fzf-native.nvim ]]

-- Config for: telescope-fzf-native.nvim
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bfzf\19load_extension\14telescope\frequire\0", "config", "telescope-fzf-native.nvim")

vim.cmd [[ packadd nvim-neoclip.lua ]]

-- Config for: nvim-neoclip.lua
try_loadstring("\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27plugins-d/nvim-neoclip\frequire\0", "config", "nvim-neoclip.lua")

vim.cmd [[ packadd telescope-github.nvim ]]

-- Config for: telescope-github.nvim
try_loadstring("\27LJ\2\nG\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\agh\19load_extension\14telescope\frequire\0", "config", "telescope-github.nvim")

vim.cmd [[ packadd telescope-bookmarks.nvim ]]

-- Config for: telescope-bookmarks.nvim
try_loadstring("\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14bookmarks\19load_extension\14telescope\frequire\0", "config", "telescope-bookmarks.nvim")

vim.cmd [[ packadd telescope-frecency.nvim ]]

-- Config for: telescope-frecency.nvim
try_loadstring("\27LJ\2\nM\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\rfrecency\19load_extension\14telescope\frequire\0", "config", "telescope-frecency.nvim")

vim.cmd [[ packadd telescope-coc.nvim ]]

-- Config for: telescope-coc.nvim
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bcoc\19load_extension\14telescope\frequire\0", "config", "telescope-coc.nvim")

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFileHistory lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFileHistory", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndoTreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndoTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TSPlaygroundToggle lua require("packer.load")({'playground'}, { cmd = "TSPlaygroundToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TSHighlightCapturesUnderCursor lua require("packer.load")({'playground'}, { cmd = "TSHighlightCapturesUnderCursor", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType lua ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "lua" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType vim ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "vim" }, _G.packer_plugins)]]
vim.cmd [[au FileType yaml ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "yaml" }, _G.packer_plugins)]]
vim.cmd [[au FileType tmux ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "tmux" }, _G.packer_plugins)]]
vim.cmd [[au FileType sh ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "sh" }, _G.packer_plugins)]]
vim.cmd [[au FileType zsh ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "zsh" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'diffview.nvim', 'gitsigns.nvim', 'HighStr.nvim', 'neogit'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
