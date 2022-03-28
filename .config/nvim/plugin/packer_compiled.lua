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
    config = { "\27LJ\2\n-\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\18plugs.HighStr\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/HighStr.nvim",
    url = "https://github.com/Pocco81/HighStr.nvim"
  },
  ["Nvim-R"] = {
    config = { "require('plugs.nvim-r')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/Nvim-R",
    url = "https://github.com/jalvesaq/Nvim-R"
  },
  ["coc-fzf"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/coc-fzf",
    url = "https://github.com/antoinemadec/coc-fzf"
  },
  ["coc.nvim"] = {
    config = { "require('plugs.coc').init()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  delimitMate = {
    config = { "require('plugs.config').delimitmate()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/delimitMate",
    url = "https://github.com/Raimondi/delimitMate"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewOpen", "DiffviewFileHistory" },
    config = { "\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\vconfig\19plugs.diffview\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["dockerfile.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/dockerfile.vim",
    url = "https://github.com/wfxr/dockerfile.vim"
  },
  fzf = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf-floaterm"] = {
    config = { "require('plugs.config').floaterm()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf-floaterm",
    url = "https://github.com/voldikss/fzf-floaterm"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\vconfig\19plugs.gitsigns\frequire\0" },
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
  hexmode = {
    config = { "vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/hexmode",
    url = "https://github.com/fidian/hexmode"
  },
  ["id3.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/id3.vim",
    url = "https://github.com/AndrewRadev/id3.vim"
  },
  indentline = {
    config = { 'require("plugs.indentline")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/indentline",
    url = "https://github.com/yggdroot/indentline"
  },
  ["info.vim"] = {
    config = { "require('plugs.config').info()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/info.vim",
    url = "https://github.com/HiPhish/info.vim"
  },
  kimbox = {
    after = { "lualine.nvim", "telescope.nvim" },
    loaded = true,
    only_config = true
  },
  ["lazygit.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lazygit.nvim",
    url = "https://github.com/kdheepak/lazygit.nvim"
  },
  ["lf-vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lf-vim",
    url = "https://github.com/camnw/lf-vim"
  },
  ["lf.vim"] = {
    config = { "require('plugs.config').lf()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lf.vim",
    url = "https://github.com/ptzz/lf.vim"
  },
  ["limelight.vim"] = {
    config = { 'require("plugs.limelight")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/limelight.vim",
    url = "https://github.com/junegunn/limelight.vim"
  },
  ["lualine.nvim"] = {
    config = { 'require("plugs.lualine")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  mkdx = {
    config = { "require('plugs.config').mkdx()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/mkdx",
    url = "https://github.com/SidOfc/mkdx"
  },
  neoformat = {
    config = { "require('plugs.neoformat')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neoformat",
    url = "https://github.com/sbdchd/neoformat"
  },
  neogit = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\vconfig\17plugs.neogit\frequire\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/neogit",
    url = "https://github.com/TimUntersberger/neogit"
  },
  neoterm = {
    config = { "require('plugs.config').neoterm()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neoterm",
    url = "https://github.com/kassio/neoterm"
  },
  nerdcommenter = {
    config = { 'require("plugs.nerdcommenter")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nerdcommenter",
    url = "https://github.com/preservim/nerdcommenter"
  },
  ["nvim-bqf"] = {
    config = { 'require("plugs.bqf")' },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "https://github.com/kevinhwang91/nvim-bqf"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20plugs.colorizer\frequire\0" },
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
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugs.nvim-neoclip\frequire\0" },
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
    after = { "nvim-gps", "nvim-tree-docs", "nvim-ts-rainbow", "nvim-treesitter-textobjects", "nvim-treesitter-refactor", "nvim-treesitter-endwise" },
    loaded = true,
    only_config = true
  },
  ["nvim-treesitter-endwise"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-endwise",
    url = "https://github.com/RRethy/nvim-treesitter-endwise"
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
  ["open-browser.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/open-browser.vim",
    url = "https://github.com/tyru/open-browser.vim"
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
  rnvimr = {
    config = { 'require("plugs.rnvimr")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/rnvimr",
    url = "https://github.com/kevinhwang91/rnvimr"
  },
  ["ron.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/ron.vim",
    url = "https://github.com/ron-rs/ron.vim"
  },
  ["rust.vim"] = {
    config = { "require('plugs.rust')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim",
    url = "https://github.com/rust-lang/rust.vim"
  },
  ["sqlite.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sqlite.lua",
    url = "https://github.com/tami5/sqlite.lua"
  },
  ["substitute.nvim"] = {
    config = { 'require("plugs.substitute")' },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/substitute.nvim",
    url = "https://github.com/gbprod/substitute.nvim"
  },
  ["targets.vim"] = {
    config = { "require('plugs.config').targets()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/targets.vim",
    url = "https://github.com/wellle/targets.vim"
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
    after = { "nvim-neoclip.lua", "telescope-bookmarks.nvim", "telescope-coc.nvim", "telescope-frecency.nvim", "telescope-fzf-native.nvim", "telescope-ghq.nvim", "telescope-ultisnips.nvim", "telescope-github.nvim" },
    config = { "require('plugs.telescope')" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["todo-comments.nvim"] = {
    config = { "require('plugs.todo-comments')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/todo-comments.nvim",
    url = "https://github.com/folke/todo-comments.nvim",
    wants = { "plenary.nvim" }
  },
  ultisnips = {
    config = { "require('plugs.config').ultisnips()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/ultisnips",
    url = "https://github.com/SirVer/ultisnips"
  },
  undotree = {
    commands = { "UndoTreeToggle" },
    config = { 'require("plugs.undotree")' },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["vim-cargo-make"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-cargo-make",
    url = "https://github.com/nastevens/vim-cargo-make"
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
  ["vim-floaterm"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-fugitive"] = {
    config = { "require('plugs.config').fugitive()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-gnupg"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-gnupg",
    url = "https://github.com/jamessan/vim-gnupg"
  },
  ["vim-go"] = {
    config = { "require('plugs.vim-go')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go",
    url = "https://github.com/fatih/vim-go"
  },
  ["vim-gutentags"] = {
    config = { "\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-gutentags.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-gutentags",
    url = "https://github.com/ludovicchabant/vim-gutentags"
  },
  ["vim-just"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-just",
    url = "https://github.com/NoahTheDuke/vim-just"
  },
  ["vim-markdown"] = {
    config = { "require('plugs.config').markdown()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown",
    url = "https://github.com/plasticboy/vim-markdown"
  },
  ["vim-pandoc-syntax"] = {
    config = { "require('plugs.config').pandoc()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-pandoc-syntax",
    url = "https://github.com/vim-pandoc/vim-pandoc-syntax"
  },
  ["vim-perl"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl",
    url = "https://github.com/vim-perl/vim-perl"
  },
  ["vim-polyglot"] = {
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-polyglot",
    url = "https://github.com/sheerun/vim-polyglot"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-rustpeg"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-rustpeg",
    url = "https://github.com/rhysd/vim-rustpeg"
  },
  ["vim-sandwich"] = {
    config = { "\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-sandwhich.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-sandwich",
    url = "https://github.com/machakann/vim-sandwich"
  },
  ["vim-snippets"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-snippets",
    url = "https://github.com/honza/vim-snippets"
  },
  ["vim-startify"] = {
    config = { "require('plugs.startify')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-startify",
    url = "https://github.com/mhinz/vim-startify"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-table-mode"] = {
    config = { "require('plugs.config').table_mode()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-table-mode",
    url = "https://github.com/dhruvasagar/vim-table-mode"
  },
  ["vim-xxdcursor"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-xxdcursor",
    url = "https://github.com/mattn/vim-xxdcursor"
  },
  vimtex = {
    config = { "require('plugs.vimtex')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vimtex",
    url = "https://github.com/lervag/vimtex"
  },
  vimwiki = {
    config = { "require('plugs.config').vimwiki()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vimwiki",
    url = "https://github.com/vimwiki/vimwiki"
  },
  vinfo = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vinfo",
    url = "https://github.com/alx741/vinfo"
  },
  ["vista.vim"] = {
    config = { 'require("plugs.vista")' },
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

-- Setup for: vim-polyglot
time([[Setup for vim-polyglot]], true)
try_loadstring("\27LJ\2\nr\0\0\2\0\3\0\0046\0\0\0005\1\2\0=\1\1\0K\0\1\0\1\r\0\0\rmarkdown\vpython\trust\tjava\blua\truby\bzig\6d\15dockerfile\frustpeg\alf\bron\22polyglot_disabled\6g\0", "setup", "vim-polyglot")
time([[Setup for vim-polyglot]], false)
time([[packadd for vim-polyglot]], true)
vim.cmd [[packadd vim-polyglot]]
time([[packadd for vim-polyglot]], false)
-- Config for: ultisnips
time([[Config for ultisnips]], true)
require('plugs.config').ultisnips()
time([[Config for ultisnips]], false)
-- Config for: vim-gutentags
time([[Config for vim-gutentags]], true)
try_loadstring("\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-gutentags.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-gutentags")
time([[Config for vim-gutentags]], false)
-- Config for: rnvimr
time([[Config for rnvimr]], true)
require("plugs.rnvimr")
time([[Config for rnvimr]], false)
-- Config for: vim-startify
time([[Config for vim-startify]], true)
require('plugs.startify')
time([[Config for vim-startify]], false)
-- Config for: neoformat
time([[Config for neoformat]], true)
require('plugs.neoformat')
time([[Config for neoformat]], false)
-- Config for: vim-fugitive
time([[Config for vim-fugitive]], true)
require('plugs.config').fugitive()
time([[Config for vim-fugitive]], false)
-- Config for: vimtex
time([[Config for vimtex]], true)
require('plugs.vimtex')
time([[Config for vimtex]], false)
-- Config for: info.vim
time([[Config for info.vim]], true)
require('plugs.config').info()
time([[Config for info.vim]], false)
-- Config for: Nvim-R
time([[Config for Nvim-R]], true)
require('plugs.nvim-r')
time([[Config for Nvim-R]], false)
-- Config for: coc.nvim
time([[Config for coc.nvim]], true)
require('plugs.coc').init()
time([[Config for coc.nvim]], false)
-- Config for: kimbox
time([[Config for kimbox]], true)
require("plugs.kimbox")
time([[Config for kimbox]], false)
-- Config for: fzf-floaterm
time([[Config for fzf-floaterm]], true)
require('plugs.config').floaterm()
time([[Config for fzf-floaterm]], false)
-- Config for: neoterm
time([[Config for neoterm]], true)
require('plugs.config').neoterm()
time([[Config for neoterm]], false)
-- Config for: vim-sandwich
time([[Config for vim-sandwich]], true)
try_loadstring("\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-sandwhich.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-sandwich")
time([[Config for vim-sandwich]], false)
-- Config for: nerdcommenter
time([[Config for nerdcommenter]], true)
require("plugs.nerdcommenter")
time([[Config for nerdcommenter]], false)
-- Config for: vim-easy-align
time([[Config for vim-easy-align]], true)
try_loadstring("\27LJ\2\n\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0*/vimscript/plugins/vim-easy-align.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-easy-align")
time([[Config for vim-easy-align]], false)
-- Config for: substitute.nvim
time([[Config for substitute.nvim]], true)
require("plugs.substitute")
time([[Config for substitute.nvim]], false)
-- Config for: vista.vim
time([[Config for vista.vim]], true)
require("plugs.vista")
time([[Config for vista.vim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
require('plugs.tree-sitter')
time([[Config for nvim-treesitter]], false)
-- Config for: vimwiki
time([[Config for vimwiki]], true)
require('plugs.config').vimwiki()
time([[Config for vimwiki]], false)
-- Config for: targets.vim
time([[Config for targets.vim]], true)
require('plugs.config').targets()
time([[Config for targets.vim]], false)
-- Config for: indentline
time([[Config for indentline]], true)
require("plugs.indentline")
time([[Config for indentline]], false)
-- Config for: lf.vim
time([[Config for lf.vim]], true)
require('plugs.config').lf()
time([[Config for lf.vim]], false)
-- Config for: todo-comments.nvim
time([[Config for todo-comments.nvim]], true)
require('plugs.todo-comments')
time([[Config for todo-comments.nvim]], false)
-- Config for: limelight.vim
time([[Config for limelight.vim]], true)
require("plugs.limelight")
time([[Config for limelight.vim]], false)
-- Config for: hexmode
time([[Config for hexmode]], true)
vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'
time([[Config for hexmode]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd nvim-treesitter-endwise ]]
vim.cmd [[ packadd nvim-ts-rainbow ]]
vim.cmd [[ packadd nvim-treesitter-textobjects ]]
vim.cmd [[ packadd nvim-treesitter-refactor ]]
vim.cmd [[ packadd nvim-tree-docs ]]
vim.cmd [[ packadd nvim-gps ]]

-- Config for: nvim-gps
require("nvim-gps").setup()

vim.cmd [[ packadd sqlite.lua ]]
vim.cmd [[ packadd lualine.nvim ]]

-- Config for: lualine.nvim
require("plugs.lualine")

vim.cmd [[ packadd popup.nvim ]]
vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
require('plugs.telescope')

vim.cmd [[ packadd telescope-bookmarks.nvim ]]

-- Config for: telescope-bookmarks.nvim
try_loadstring("\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14bookmarks\19load_extension\14telescope\frequire\0", "config", "telescope-bookmarks.nvim")

vim.cmd [[ packadd telescope-coc.nvim ]]

-- Config for: telescope-coc.nvim
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bcoc\19load_extension\14telescope\frequire\0", "config", "telescope-coc.nvim")

vim.cmd [[ packadd telescope-frecency.nvim ]]

-- Config for: telescope-frecency.nvim
try_loadstring("\27LJ\2\nM\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\rfrecency\19load_extension\14telescope\frequire\0", "config", "telescope-frecency.nvim")

vim.cmd [[ packadd telescope-fzf-native.nvim ]]

-- Config for: telescope-fzf-native.nvim
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bfzf\19load_extension\14telescope\frequire\0", "config", "telescope-fzf-native.nvim")

vim.cmd [[ packadd nvim-neoclip.lua ]]

-- Config for: nvim-neoclip.lua
try_loadstring("\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugs.nvim-neoclip\frequire\0", "config", "nvim-neoclip.lua")

vim.cmd [[ packadd telescope-ghq.nvim ]]

-- Config for: telescope-ghq.nvim
try_loadstring("\27LJ\2\nH\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\bghq\19load_extension\14telescope\frequire\0", "config", "telescope-ghq.nvim")

vim.cmd [[ packadd telescope-ultisnips.nvim ]]

-- Config for: telescope-ultisnips.nvim
try_loadstring("\27LJ\2\nN\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\14ultisnips\19load_extension\14telescope\frequire\0", "config", "telescope-ultisnips.nvim")

vim.cmd [[ packadd telescope-github.nvim ]]

-- Config for: telescope-github.nvim
try_loadstring("\27LJ\2\nG\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\agh\19load_extension\14telescope\frequire\0", "config", "telescope-github.nvim")

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TSPlaygroundToggle lua require("packer.load")({'playground'}, { cmd = "TSPlaygroundToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndoTreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndoTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TSHighlightCapturesUnderCursor lua require("packer.load")({'playground'}, { cmd = "TSHighlightCapturesUnderCursor", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFileHistory lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFileHistory", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType vimwiki ++once lua require("packer.load")({'vim-pandoc-syntax', 'mkdx', 'vim-markdown', 'vim-table-mode'}, { ft = "vimwiki" }, _G.packer_plugins)]]
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust.vim'}, { ft = "rust" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
vim.cmd [[au FileType perl ++once lua require("packer.load")({'vim-perl'}, { ft = "perl" }, _G.packer_plugins)]]
vim.cmd [[au FileType sh ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "sh" }, _G.packer_plugins)]]
vim.cmd [[au FileType lua ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "lua" }, _G.packer_plugins)]]
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
vim.cmd [[au FileType pandoc ++once lua require("packer.load")({'vim-pandoc-syntax'}, { ft = "pandoc" }, _G.packer_plugins)]]
vim.cmd [[au FileType yaml ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "yaml" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'vim-pandoc-syntax', 'nvim-colorizer.lua', 'mkdx', 'vim-markdown', 'vim-table-mode'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType tmux ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "tmux" }, _G.packer_plugins)]]
vim.cmd [[au FileType vim ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "vim" }, _G.packer_plugins)]]
vim.cmd [[au FileType zsh ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "zsh" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'delimitMate'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'diffview.nvim', 'gitsigns.nvim', 'HighStr.nvim', 'neogit'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
