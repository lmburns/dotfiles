-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = true
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
  ["Comment.nvim"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/Comment.nvim/after/plugin/Comment.lua" },
    config = { "require('plugs.comment')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  ["FixCursorHold.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/FixCursorHold.nvim",
    url = "https://github.com/antoinemadec/FixCursorHold.nvim"
  },
  ["HighStr.nvim"] = {
    config = { "require('plugs.HighStr')" },
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
  ["Sakura.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/Sakura.nvim",
    url = "https://github.com/numToStr/Sakura.nvim"
  },
  ScratchPad = {
    config = { "require('plugs.config').scratchpad()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/ScratchPad",
    url = "https://github.com/FraserLee/ScratchPad"
  },
  ["Spacegray.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/Spacegray.vim",
    url = "https://github.com/ackyshake/Spacegray.vim"
  },
  ["aerial.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/aerial.nvim",
    url = "https://github.com/stevearc/aerial.nvim"
  },
  ["arshlib.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/arshlib.nvim",
    url = "https://github.com/arsham/arshlib.nvim"
  },
  ["better-escape.nvim"] = {
    config = { "require('plugs.config').better_esc()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/better-escape.nvim",
    url = "https://github.com/max397574/better-escape.nvim"
  },
  bogster = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/bogster",
    url = "https://github.com/vv9k/bogster"
  },
  ["bufdelete.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/bufdelete.nvim",
    url = "https://github.com/famiu/bufdelete.nvim"
  },
  ["bufferize.vim"] = {
    commands = { "Bufferize" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/bufferize.vim",
    url = "https://github.com/AndrewRadev/bufferize.vim"
  },
  ["bufferline.nvim"] = {
    config = { "require('plugs.bufferline')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["coc-fzf"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-fzf/after/plugin/coc_fzf.vim" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-fzf",
    url = "https://github.com/antoinemadec/coc-fzf"
  },
  ["coc-kvs"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-kvs",
    url = "https://github.com/kevinhwang91/coc-kvs"
  },
  ["coc.nvim"] = {
    after = { "coc-kvs", "coc-fzf" },
    loaded = true,
    only_config = true
  },
  ["comment-box.nvim"] = {
    config = { "require('plugs.config').comment_box()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/comment-box.nvim",
    url = "https://github.com/LudoPinelli/comment-box.nvim"
  },
  ["crates.nvim"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/crates.nvim/after/plugin/cmp_crates.lua" },
    config = { "require('plugs.config').crates()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/crates.nvim",
    url = "https://github.com/Saecki/crates.nvim"
  },
  ["daycula-vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/daycula-vim",
    url = "https://github.com/ghifarit53/daycula-vim"
  },
  ["dial.nvim"] = {
    config = { "require('plugs.dial')" },
    keys = { { "n", "+" }, { "n", "_" }, { "v", "+" }, { "v", "_" }, { "v", "g+" }, { "v", "g_" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/dial.nvim",
    url = "https://github.com/monaqa/dial.nvim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles", "DiffviewLog", "DiffviewOpen", "DiffviewRefresh", "DiffviewToggleFiles" },
    config = { "require('plugs.diffview')" },
    keys = { { "n", "<Leader>g;" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["dressing.nvim"] = {
    config = { "require('plugs.dressing')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/dressing.nvim",
    url = "https://github.com/stevearc/dressing.nvim"
  },
  edge = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/edge",
    url = "https://github.com/sainnhe/edge"
  },
  everforest = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/everforest",
    url = "https://github.com/sainnhe/everforest"
  },
  ["filetype.nvim"] = {
    config = { "require('plugs.filetype')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/filetype.nvim",
    url = "https://github.com/nathom/filetype.nvim"
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
  ["fzf-lua"] = {
    config = { "require('plugs.fzf-lua')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf-lua",
    url = "https://github.com/ibhagwan/fzf-lua"
  },
  ["fzf.vim"] = {
    config = { "require('plugs.fzf')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["fzy-lua-native"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzy-lua-native",
    url = "https://github.com/romgrk/fzy-lua-native"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plugs.gitsigns')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["gruvbox-flat.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gruvbox-flat.nvim",
    url = "https://github.com/eddyekofo94/gruvbox-flat.nvim"
  },
  ["gruvbox-material"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gruvbox-material",
    url = "https://github.com/sainnhe/gruvbox-material"
  },
  hexmode = {
    config = { "vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/hexmode",
    url = "https://github.com/fidian/hexmode"
  },
  ["hlargs.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/hlargs.nvim",
    url = "https://github.com/m-demare/hlargs.nvim"
  },
  ["hop.nvim"] = {
    config = { "require('plugs.hop')" },
    keys = { { "n", "f" }, { "x", "f" }, { "o", "f" }, { "n", "F" }, { "x", "F" }, { "o", "F" }, { "n", "t" }, { "x", "t" }, { "o", "t" }, { "n", "T" }, { "x", "T" }, { "o", "T" }, { "n", "<Leader><Leader>h" }, { "n", "<Leader><Leader>j" }, { "n", "<Leader><Leader>k" }, { "n", "<Leader><Leader>l" }, { "n", "<Leader><Leader>J" }, { "n", "<Leader><Leader>K" }, { "n", "<Leader><Leader>/" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/hop.nvim",
    url = "https://github.com/phaazon/hop.nvim"
  },
  ["iceberg.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/iceberg.vim",
    url = "https://github.com/cocopon/iceberg.vim"
  },
  ["id3.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/id3.vim",
    url = "https://github.com/AndrewRadev/id3.vim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/impatient.nvim",
    url = "https://github.com/lewis6991/impatient.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "require('plugs.indent_blankline')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["info.vim"] = {
    config = { "require('plugs.config').info()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/info.vim",
    url = "https://github.com/HiPhish/info.vim"
  },
  ["iswap.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/iswap.nvim",
    url = "https://github.com/mizlan/iswap.nvim"
  },
  ["jellybeans-nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/jellybeans-nvim",
    url = "https://github.com/metalelf0/jellybeans-nvim"
  },
  ["kanagawa.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/kanagawa.nvim",
    url = "https://github.com/rebelot/kanagawa.nvim"
  },
  kimbox = {
    after = { "vimwiki", "indent-blankline.nvim", "nvim-scrollbar", "telescope.nvim", "lualine.nvim", "bufferline.nvim" },
    loaded = true,
    only_config = true
  },
  ["lazygit.nvim"] = {
    config = { "require('plugs.config').lazygit()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lazygit.nvim",
    url = "https://github.com/kdheepak/lazygit.nvim"
  },
  ["legendary.nvim"] = {
    config = { "require('plugs.legendary')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/legendary.nvim",
    url = "https://github.com/mrjones2014/legendary.nvim"
  },
  ["lf-vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim",
    url = "https://github.com/camnw/lf-vim"
  },
  ["lf.nvim"] = {
    config = { "require('plugs.config').lfnvim()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lf.nvim",
    url = "/home/lucas/projects/nvim/lf.nvim"
  },
  ["lf.vim"] = {
    config = { "require('plugs.config').lf()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lf.vim",
    url = "https://github.com/ptzz/lf.vim"
  },
  ["listish.nvim"] = {
    config = { "require('plugs.config').listish()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/listish.nvim",
    url = "https://github.com/arsham/listish.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lua-dev.nvim",
    url = "https://github.com/max397574/lua-dev.nvim"
  },
  ["lualine.nvim"] = {
    after = { "bufferline.nvim" },
    config = { "require('plugs.lualine')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lush.nvim",
    url = "https://github.com/rktjmp/lush.nvim"
  },
  ["luv-vimdocs"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/luv-vimdocs",
    url = "https://github.com/nanotee/luv-vimdocs"
  },
  ["marks.nvim"] = {
    config = { "require('plugs.marks')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/marks.nvim",
    url = "https://github.com/chentau/marks.nvim"
  },
  ["material.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/material.nvim",
    url = "https://github.com/marko-cerovac/material.nvim"
  },
  melange = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/melange",
    url = "https://github.com/savq/melange"
  },
  ["minimap.vim"] = {
    config = { "require('plugs.config').minimap()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/minimap.vim",
    url = "https://github.com/wfxr/minimap.vim"
  },
  miramare = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/miramare",
    url = "https://github.com/franbach/miramare"
  },
  mkdx = {
    config = { "\27LJ\2\nq\0\0\6\0\a\0\v6\0\0\0009\0\1\0'\2\2\0006\3\3\0009\3\4\3'\5\5\0B\3\2\2'\4\6\0&\2\4\2B\0\2\1K\0\1\0 /vimscript/plugins/mkdx.vim\vconfig\fstdpath\afn\fsource \bcmd\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/mkdx",
    url = "https://github.com/SidOfc/mkdx"
  },
  ["move.nvim"] = {
    config = { "require('plugs.config').move()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/move.nvim",
    url = "https://github.com/fedepujol/move.nvim"
  },
  ["neodark.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neodark.vim",
    url = "https://github.com/KeitaNakamura/neodark.vim"
  },
  neoformat = {
    config = { "require('plugs.neoformat')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neoformat",
    url = "https://github.com/sbdchd/neoformat"
  },
  neogen = {
    config = { "require('plugs.config').neogen()" },
    keys = { { "n", "<Leader>dg" }, { "n", "<Leader>df" }, { "n", "<Leader>dc" } },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/neogen",
    url = "https://github.com/danymat/neogen"
  },
  neogit = {
    config = { "require('plugs.neogit')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neogit",
    url = "https://github.com/TimUntersberger/neogit"
  },
  ["night-owl.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/night-owl.vim",
    url = "https://github.com/haishanh/night-owl.vim"
  },
  ["nightfox.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nightfox.nvim",
    url = "https://github.com/EdenEast/nightfox.nvim"
  },
  ["nlua.nvim"] = {
    config = { "require('plugs.config').nlua()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nlua.nvim",
    url = "https://github.com/tjdevries/nlua.nvim"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "require('plugs.autopairs')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-bqf"] = {
    config = { "require('plugs.config').bqf()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "https://github.com/kevinhwang91/nvim-bqf"
  },
  ["nvim-colorizer.lua"] = {
    commands = { "ColorizerToggle" },
    config = { "require('plugs.config').colorizer()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-dap"] = {
    after = { "telescope-dap.nvim", "nvim-dap-python", "nvim-dap-ui" },
    config = { "require('plugs.dap').config()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap",
    wants = { "one-small-step-for-vimkind" }
  },
  ["nvim-dap-python"] = {
    config = { "\27LJ\2\nv\0\0\6\0\a\0\f6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0\18\4\2\0009\2\4\0026\5\5\0009\5\6\5B\2\3\0A\0\0\1K\0\1\0\15PYENV_ROOT\benv\vformat\20%s/shims/python\nsetup\15dap-python\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-python",
    url = "https://github.com/mfussenegger/nvim-dap-python",
    wants = { "nvim-dap" }
  },
  ["nvim-dap-ui"] = {
    config = { "\27LJ\2\n3\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\ndapui\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-ui",
    url = "https://github.com/rcarriga/nvim-dap-ui"
  },
  ["nvim-gps"] = {
    config = { 'require("nvim-gps").setup()' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-gps",
    url = "https://github.com/SmiteshP/nvim-gps"
  },
  ["nvim-hclipboard"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-hclipboard",
    url = "https://github.com/kevinhwang91/nvim-hclipboard"
  },
  ["nvim-hlslens"] = {
    after = { "nvim-scrollbar" },
    config = { "require('plugs.config').hlslens()" },
    keys = { { "n", "n" }, { "x", "n" }, { "o", "n" }, { "n", "N" }, { "x", "N" }, { "o", "N" }, { "n", "/" }, { "n", "?" }, { "n", "*" }, { "x", "*" }, { "n", "#" }, { "x", "#" }, { "n", "g*" }, { "x", "g*" }, { "n", "g#" }, { "x", "g#" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-hlslens",
    url = "https://github.com/kevinhwang91/nvim-hlslens"
  },
  ["nvim-luapad"] = {
    commands = { "Luapad", "LuaRun" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-luapad",
    url = "https://github.com/rafcamlet/nvim-luapad"
  },
  ["nvim-luaref"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-luaref",
    url = "https://github.com/milisims/nvim-luaref"
  },
  ["nvim-notify"] = {
    config = { "require('plugs.config').notify()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-regexplainer"] = {
    config = { "require('plugs.config').regexplainer()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-regexplainer",
    url = "https://github.com/bennypowers/nvim-regexplainer"
  },
  ["nvim-reload"] = {
    config = { "require('plugs.nvim-reload')" },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-reload",
    url = "/home/lucas/.config/nvim/lua/plugs/nvim-reload"
  },
  ["nvim-scrollbar"] = {
    config = { "require('plugs.scrollbar')" },
    load_after = {
      ["nvim-hlslens"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-scrollbar",
    url = "https://github.com/petertriho/nvim-scrollbar"
  },
  ["nvim-tree-docs"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-tree-docs",
    url = "https://github.com/nvim-treesitter/nvim-tree-docs"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
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
  ["nvim-trevJ.lua"] = {
    config = { "require('plugs.config').trevj()" },
    keys = { { "n", "gJ" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-trevJ.lua",
    url = "https://github.com/AckslD/nvim-trevJ.lua"
  },
  ["nvim-ts-autotag"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["nvim-ts-context-commentstring"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-ts-context-commentstring",
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["nvim-window"] = {
    config = { "require('plugs.config').window_picker()" },
    keys = { { "n", "<M-->" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-window",
    url = "https://gitlab.com/yorickpeterse/nvim-window"
  },
  ["nvim.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim.lua",
    url = "https://github.com/norcalli/nvim.lua"
  },
  nvim_context_vt = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim_context_vt",
    url = "https://github.com/haringsrob/nvim_context_vt"
  },
  ["oceanic-material"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/oceanic-material",
    url = "https://github.com/glepnir/oceanic-material"
  },
  ["one-small-step-for-vimkind"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/one-small-step-for-vimkind",
    url = "https://github.com/jbyuki/one-small-step-for-vimkind"
  },
  ["onenord.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/onenord.nvim",
    url = "https://github.com/rmehri01/onenord.nvim"
  },
  ["open-browser.vim"] = {
    config = { "require('plugs.config').open_browser()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/open-browser.vim",
    url = "https://github.com/tyru/open-browser.vim"
  },
  ["package-info.nvim"] = {
    config = { "require('plugs.config').package_info()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/package-info.nvim",
    url = "https://github.com/vuki656/package-info.nvim"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["persistence.nvim"] = {
    config = { "require('plugs.config').persistence()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/persistence.nvim",
    url = "https://github.com/folke/persistence.nvim"
  },
  playground = {
    load_after = {},
    loaded = true,
    needs_bufread = true,
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
  ["pretty-fold.nvim"] = {
    config = { "require('plugs.pretty-fold')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/pretty-fold.nvim",
    url = "https://github.com/anuvyklack/pretty-fold.nvim"
  },
  ["registers.nvim"] = {
    config = { "require('plugs.config').registers()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/registers.nvim",
    url = "https://github.com/tversteeg/registers.nvim"
  },
  rnvimr = {
    config = { "require('plugs.rnvimr')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/rnvimr",
    url = "https://github.com/kevinhwang91/rnvimr"
  },
  ["ron.vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim",
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
  ["smart-splits.nvim"] = {
    config = { "require('plugs.config').smartsplits()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/smart-splits.nvim",
    url = "https://github.com/mrjones2014/smart-splits.nvim"
  },
  sonokai = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sonokai",
    url = "https://github.com/sainnhe/sonokai"
  },
  spaceduck = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/spaceduck",
    url = "https://github.com/pineapplegiant/spaceduck"
  },
  ["specs.nvim"] = {
    config = { "require('plugs.config').specs()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/specs.nvim",
    url = "https://github.com/edluffy/specs.nvim"
  },
  ["spellsitter.nvim"] = {
    config = { 'require("spellsitter").setup()' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/spellsitter.nvim",
    url = "https://github.com/lewis6991/spellsitter.nvim"
  },
  ["sqlite.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sqlite.lua",
    url = "https://github.com/tami5/sqlite.lua"
  },
  ["substitute.nvim"] = {
    config = { "require('plugs.substitute')" },
    keys = { { "n", "s" }, { "n", "ss" }, { "n", "se" }, { "n", "sr" }, { "n", "<Leader>sr" }, { "n", "sS" }, { "n", "sx" }, { "n", "sxx" }, { "n", "sxc" }, { "x", "s" }, { "x", "X" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/substitute.nvim",
    url = "https://github.com/gbprod/substitute.nvim"
  },
  ["suda.vim"] = {
    commands = { "SudaRead", "SudaWrite" },
    config = { "require('plugs.config').suda()" },
    keys = { { "n", "<Leader>W" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/suda.vim",
    url = "https://github.com/kevinhwang91/suda.vim"
  },
  ["targets.vim"] = {
    config = { "require('plugs.config').targets()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/targets.vim",
    url = "https://github.com/wellle/targets.vim"
  },
  ["telescope-bookmarks.nvim"] = {
    config = { 'require("telescope").load_extension("bookmarks")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-bookmarks.nvim",
    url = "https://github.com/dhruvmanila/telescope-bookmarks.nvim"
  },
  ["telescope-coc.nvim"] = {
    config = { 'require("telescope").load_extension("coc")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-coc.nvim",
    url = "https://github.com/fannheyward/telescope-coc.nvim"
  },
  ["telescope-dap.nvim"] = {
    config = { 'require("telescope").load_extension("dap")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-dap.nvim",
    url = "https://github.com/nvim-telescope/telescope-dap.nvim"
  },
  ["telescope-file-browser.nvim"] = {
    config = { 'require("telescope").load_extension("file_browser")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-frecency.nvim"] = {
    config = { 'require("telescope").load_extension("frecency")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-frecency.nvim",
    url = "https://github.com/nvim-telescope/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    config = { 'require("telescope").load_extension("fzf")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-ghq.nvim"] = {
    config = { 'require("telescope").load_extension("ghq")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ghq.nvim",
    url = "https://github.com/nvim-telescope/telescope-ghq.nvim"
  },
  ["telescope-github.nvim"] = {
    config = { 'require("telescope").load_extension("gh")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-github.nvim",
    url = "https://github.com/nvim-telescope/telescope-github.nvim"
  },
  ["telescope-heading.nvim"] = {
    config = { 'require("telescope").load_extension("heading")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-heading.nvim",
    url = "https://github.com/crispgm/telescope-heading.nvim"
  },
  ["telescope-hop.nvim"] = {
    config = { 'require("telescope").load_extension("hop")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-hop.nvim",
    url = "https://github.com/nvim-telescope/telescope-hop.nvim"
  },
  ["telescope-packer.nvim"] = {
    config = { "\27LJ\2\nù\1\0\1\4\0\b\0\0196\1\0\0009\1\1\1'\3\2\0B\1\2\0016\1\3\0'\3\4\0B\1\2\0029\1\5\1'\3\6\0B\1\2\0016\1\3\0'\3\4\0B\1\2\0029\1\a\0019\1\6\0019\1\6\1\18\3\0\0B\1\2\1K\0\1\0\15extensions\vpacker\19load_extension\14telescope\frequire\16packer.nvim\fpackadd\aexA\1\0\3\0\4\0\0066\0\0\0'\2\1\0B\0\2\0023\1\3\0=\1\2\0K\0\1\0\0\vpacker\22telescope.builtin\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-packer.nvim",
    url = "https://github.com/nvim-telescope/telescope-packer.nvim",
    wants = { "telescope.nvim", "packer.nvim" }
  },
  ["telescope-rualdi.nvim"] = {
    config = { 'require("telescope").load_extension("rualdi")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-rualdi.nvim",
    url = "/home/lucas/projects/nvim/telescope-rualdi.nvim"
  },
  ["telescope-smart-history.nvim"] = {
    config = { 'require("telescope").load_extension("smart_history")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-smart-history.nvim",
    url = "https://github.com/nvim-telescope/telescope-smart-history.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    config = { 'require("telescope").load_extension("ui-select")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope-ultisnips.nvim"] = {
    config = { 'require("telescope").load_extension("ultisnips")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ultisnips.nvim",
    url = "https://github.com/fhill2/telescope-ultisnips.nvim"
  },
  ["telescope-zoxide"] = {
    config = { 'require("telescope").load_extension("zoxide")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-zoxide",
    url = "https://github.com/jvgrootveld/telescope-zoxide"
  },
  ["telescope.nvim"] = {
    after = { "telescope-zoxide", "telescope-smart-history.nvim", "telescope-ui-select.nvim", "telescope-packer.nvim", "telescope-heading.nvim", "telescope-bookmarks.nvim", "telescope-ghq.nvim", "nvim-dap", "telescope-ultisnips.nvim", "telescope-github.nvim", "telescope-coc.nvim", "telescope-file-browser.nvim", "telescope-rualdi.nvim", "telescope-fzf-native.nvim", "urlview.nvim", "telescope-hop.nvim", "telescope-frecency.nvim" },
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
  ["toggleterm.nvim"] = {
    commands = { "T", "TE" },
    config = { "require('plugs.neoterm')" },
    keys = { { "", "gxx" }, { "", "gx" }, { "", "<C-\\>" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/toggleterm.nvim",
    url = "https://github.com/akinsho/toggleterm.nvim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/tokyonight.nvim",
    url = "https://github.com/folke/tokyonight.nvim"
  },
  ["treesitter-unit"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/treesitter-unit",
    url = "https://github.com/David-Kunz/treesitter-unit"
  },
  ["twilight.nvim"] = {
    config = { "require('plugs.twilight')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/twilight.nvim",
    url = "https://github.com/folke/twilight.nvim"
  },
  ultisnips = {
    config = { "require('plugs.config').ultisnips()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/ultisnips",
    url = "https://github.com/SirVer/ultisnips"
  },
  undotree = {
    commands = { "UndoTreeToggle" },
    config = { "require('plugs.undotree')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["urlview.nvim"] = {
    config = { "require('plugs.config').urlview()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/urlview.nvim",
    url = "https://github.com/axieax/urlview.nvim"
  },
  ["vCoolor.vim"] = {
    config = { "require('plugs.config').vcoolor()" },
    keys = { { "n", "<Leader>pc" }, { "n", "<Leader>yb" }, { "n", "<Leader>yr" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vCoolor.vim",
    url = "https://github.com/KabbAmine/vCoolor.vim"
  },
  ["vim-abolish"] = {
    commands = { "S", "Subvert", "Abolish" },
    keys = { { "n", "cr" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-abolish",
    url = "https://github.com/tpope/vim-abolish"
  },
  ["vim-anyfold"] = {
    commands = { "AnyFoldActivate" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-anyfold",
    url = "https://github.com/pseewald/vim-anyfold"
  },
  ["vim-asterisk"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-asterisk",
    url = "https://github.com/haya14busa/vim-asterisk"
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
  ["vim-dogrun"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-dogrun",
    url = "https://github.com/wadackel/vim-dogrun"
  },
  ["vim-easy-align"] = {
    config = { "require('plugs.easy-align')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-easy-align",
    url = "https://github.com/junegunn/vim-easy-align"
  },
  ["vim-floaterm"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-flog"] = {
    commands = { "Flog", "Flogsplit" },
    config = { "require('plugs.flog')" },
    keys = { { "n", "<Leader>gl" }, { "n", "<Leader>gf" } },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-flog",
    url = "https://github.com/rbong/vim-flog"
  },
  ["vim-fugitive"] = {
    commands = { "0Git", "G", "GBrowse", "Gcd", "Gclog", "GDelete", "Gdiffsplit", "Gedit", "Ggrep", "Ghdiffsplit", "Git", "Glcd", "Glgrep", "Gllog", "GMove", "Gpedit", "Gread", "GRemove", "GRename", "Gsplit", "Gtabedit", "GUnlink", "Gvdiffsplit", "Gvsplit", "Gwq", "Gwrite" },
    config = { "require('plugs.fugitive')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-gh-line"] = {
    config = { "require('plugs.config').ghline()" },
    keys = { { "n", "<Leader>gO" }, { "n", "<Leader>gL" }, { "x", "<Leader>gL" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-gh-line",
    url = "https://github.com/ruanyl/vim-gh-line"
  },
  ["vim-gnupg"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-gnupg",
    url = "https://github.com/jamessan/vim-gnupg"
  },
  ["vim-go"] = {
    config = { "require('plugs.go')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go",
    url = "https://github.com/fatih/vim-go"
  },
  ["vim-grepper"] = {
    commands = { "Grepper" },
    config = { "require('plugs.config').grepper()" },
    keys = { { "n", "gs" }, { "x", "gs" }, { "n", "<Leader>rg" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-grepper",
    url = "https://github.com/mhinz/vim-grepper"
  },
  ["vim-gutentags"] = {
    after = { "vista.vim" },
    loaded = true,
    only_config = true
  },
  ["vim-indent-object"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-indent-object",
    url = "https://github.com/michaeljsmith/vim-indent-object"
  },
  ["vim-just"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just",
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
  ["vim-matchup"] = {
    config = { "require('plugs.config').matchup()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-matchup",
    url = "https://github.com/andymass/vim-matchup"
  },
  ["vim-nightfly-guicolors"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-nightfly-guicolors",
    url = "https://github.com/bluz71/vim-nightfly-guicolors"
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
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-rhubarb",
    url = "https://github.com/tpope/vim-rhubarb"
  },
  ["vim-rustpeg"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg",
    url = "https://github.com/rhysd/vim-rustpeg"
  },
  ["vim-sandwich"] = {
    config = { "require('plugs.config').sandwhich()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-sandwich",
    url = "https://github.com/machakann/vim-sandwich"
  },
  ["vim-slime"] = {
    config = { "require('plugs.config').slime()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-slime",
    url = "https://github.com/jpalardy/vim-slime"
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
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vimwiki",
    url = "https://github.com/vimwiki/vimwiki"
  },
  vinfo = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vinfo",
    url = "https://github.com/alx741/vinfo"
  },
  ["vista.vim"] = {
    config = { "require('plugs.vista')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vista.vim",
    url = "https://github.com/liuchengxu/vista.vim"
  },
  ["which-key.nvim"] = {
    config = { "require('plugs.which-key')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  },
  ["wilder.nvim"] = {
    config = { "require('plugs.wilder')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/wilder.nvim",
    url = "https://github.com/gelguy/wilder.nvim"
  },
  ["yanky.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/yanky.nvim",
    url = "https://github.com/gbprod/yanky.nvim"
  },
  ["zen-mode.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/zen-mode.nvim",
    url = "https://github.com/folke/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
local module_lazy_loads = {
  ["^lua%-dev"] = "lua-dev.nvim",
  ["^persistence"] = "persistence.nvim"
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
try_loadstring("\27LJ\2\n§\1\0\0\2\0\3\0\0046\0\0\0005\1\2\0=\1\1\0K\0\1\0\1\23\0\0\rmarkdown\frustpeg\alf\bron\ncmake\bcss\6d\tdart\15dockerfile\ago\ngomod\thtml\tjava\tmake\tperl\vpython\nquery\truby\trust\tscss\bzig\bzsh\22polyglot_disabled\6g\0", "setup", "vim-polyglot")
time([[Setup for vim-polyglot]], false)
time([[packadd for vim-polyglot]], true)
vim.cmd [[packadd vim-polyglot]]
time([[packadd for vim-polyglot]], false)
-- Setup for: vCoolor.vim
time([[Setup for vCoolor.vim]], true)
vim.g.vcoolor_disable_mappings = 1 vim.g.vcoolor_lowercase = 1
time([[Setup for vCoolor.vim]], false)
-- Setup for: vim-gh-line
time([[Setup for vim-gh-line]], true)
vim.g.gh_line_blame_map_default = 0
time([[Setup for vim-gh-line]], false)
-- Setup for: nvim-dap
time([[Setup for nvim-dap]], true)
require('plugs.dap').setup()
time([[Setup for nvim-dap]], false)
-- Setup for: vim-anyfold
time([[Setup for vim-anyfold]], true)
vim.g.anyfold_fold_display = 0
time([[Setup for vim-anyfold]], false)
-- Config for: package-info.nvim
time([[Config for package-info.nvim]], true)
require('plugs.config').package_info()
time([[Config for package-info.nvim]], false)
-- Config for: ultisnips
time([[Config for ultisnips]], true)
require('plugs.config').ultisnips()
time([[Config for ultisnips]], false)
-- Config for: open-browser.vim
time([[Config for open-browser.vim]], true)
require('plugs.config').open_browser()
time([[Config for open-browser.vim]], false)
-- Config for: move.nvim
time([[Config for move.nvim]], true)
require('plugs.config').move()
time([[Config for move.nvim]], false)
-- Config for: vimtex
time([[Config for vimtex]], true)
require('plugs.vimtex')
time([[Config for vimtex]], false)
-- Config for: hexmode
time([[Config for hexmode]], true)
vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'
time([[Config for hexmode]], false)
-- Config for: vim-matchup
time([[Config for vim-matchup]], true)
require('plugs.config').matchup()
time([[Config for vim-matchup]], false)
-- Config for: comment-box.nvim
time([[Config for comment-box.nvim]], true)
require('plugs.config').comment_box()
time([[Config for comment-box.nvim]], false)
-- Config for: minimap.vim
time([[Config for minimap.vim]], true)
require('plugs.config').minimap()
time([[Config for minimap.vim]], false)
-- Config for: specs.nvim
time([[Config for specs.nvim]], true)
require('plugs.config').specs()
time([[Config for specs.nvim]], false)
-- Config for: better-escape.nvim
time([[Config for better-escape.nvim]], true)
require('plugs.config').better_esc()
time([[Config for better-escape.nvim]], false)
-- Config for: coc.nvim
time([[Config for coc.nvim]], true)
require('plugs.coc').tag_cmd()
time([[Config for coc.nvim]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
require('plugs.gitsigns')
time([[Config for gitsigns.nvim]], false)
-- Config for: vim-easy-align
time([[Config for vim-easy-align]], true)
require('plugs.easy-align')
time([[Config for vim-easy-align]], false)
-- Config for: marks.nvim
time([[Config for marks.nvim]], true)
require('plugs.marks')
time([[Config for marks.nvim]], false)
-- Config for: smart-splits.nvim
time([[Config for smart-splits.nvim]], true)
require('plugs.config').smartsplits()
time([[Config for smart-splits.nvim]], false)
-- Config for: vim-gutentags
time([[Config for vim-gutentags]], true)
try_loadstring("\27LJ\2\n~\0\0\6\0\a\0\f6\0\0\0009\0\1\0'\2\2\0B\0\2\0026\1\3\0009\1\4\1'\3\5\0\18\4\0\0'\5\6\0&\3\5\3B\1\2\1K\0\1\0)/vimscript/plugins/vim-gutentags.vim\fsource \bcmd\bvim\vconfig\fstdpath\afn\0", "config", "vim-gutentags")
time([[Config for vim-gutentags]], false)
-- Config for: fzf.vim
time([[Config for fzf.vim]], true)
require('plugs.fzf')
time([[Config for fzf.vim]], false)
-- Config for: ScratchPad
time([[Config for ScratchPad]], true)
require('plugs.config').scratchpad()
time([[Config for ScratchPad]], false)
-- Config for: lazygit.nvim
time([[Config for lazygit.nvim]], true)
require('plugs.config').lazygit()
time([[Config for lazygit.nvim]], false)
-- Config for: fzf-lua
time([[Config for fzf-lua]], true)
require('plugs.fzf-lua')
time([[Config for fzf-lua]], false)
-- Config for: fzf-floaterm
time([[Config for fzf-floaterm]], true)
require('plugs.config').floaterm()
time([[Config for fzf-floaterm]], false)
-- Config for: rnvimr
time([[Config for rnvimr]], true)
require('plugs.rnvimr')
time([[Config for rnvimr]], false)
-- Config for: vim-startify
time([[Config for vim-startify]], true)
require('plugs.startify')
time([[Config for vim-startify]], false)
-- Config for: filetype.nvim
time([[Config for filetype.nvim]], true)
require('plugs.filetype')
time([[Config for filetype.nvim]], false)
-- Config for: listish.nvim
time([[Config for listish.nvim]], true)
require('plugs.config').listish()
time([[Config for listish.nvim]], false)
-- Config for: pretty-fold.nvim
time([[Config for pretty-fold.nvim]], true)
require('plugs.pretty-fold')
time([[Config for pretty-fold.nvim]], false)
-- Config for: info.vim
time([[Config for info.vim]], true)
require('plugs.config').info()
time([[Config for info.vim]], false)
-- Config for: Nvim-R
time([[Config for Nvim-R]], true)
require('plugs.nvim-r')
time([[Config for Nvim-R]], false)
-- Config for: neogit
time([[Config for neogit]], true)
require('plugs.neogit')
time([[Config for neogit]], false)
-- Config for: lf.nvim
time([[Config for lf.nvim]], true)
require('plugs.config').lfnvim()
time([[Config for lf.nvim]], false)
-- Config for: vim-sandwich
time([[Config for vim-sandwich]], true)
require('plugs.config').sandwhich()
time([[Config for vim-sandwich]], false)
-- Config for: registers.nvim
time([[Config for registers.nvim]], true)
require('plugs.config').registers()
time([[Config for registers.nvim]], false)
-- Config for: legendary.nvim
time([[Config for legendary.nvim]], true)
require('plugs.legendary')
time([[Config for legendary.nvim]], false)
-- Config for: lf.vim
time([[Config for lf.vim]], true)
require('plugs.config').lf()
time([[Config for lf.vim]], false)
-- Config for: todo-comments.nvim
time([[Config for todo-comments.nvim]], true)
require('plugs.todo-comments')
time([[Config for todo-comments.nvim]], false)
-- Config for: wilder.nvim
time([[Config for wilder.nvim]], true)
require('plugs.wilder')
time([[Config for wilder.nvim]], false)
-- Config for: kimbox
time([[Config for kimbox]], true)
require('plugs.kimbox')
time([[Config for kimbox]], false)
-- Config for: nvim-notify
time([[Config for nvim-notify]], true)
require('plugs.config').notify()
time([[Config for nvim-notify]], false)
-- Config for: targets.vim
time([[Config for targets.vim]], true)
require('plugs.config').targets()
time([[Config for targets.vim]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
require('plugs.which-key')
time([[Config for which-key.nvim]], false)
-- Config for: neoformat
time([[Config for neoformat]], true)
require('plugs.neoformat')
time([[Config for neoformat]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd indent-blankline.nvim ]]

-- Config for: indent-blankline.nvim
require('plugs.indent_blankline')

vim.cmd [[ packadd vimwiki ]]

-- Config for: vimwiki
require('plugs.config').vimwiki()

vim.cmd [[ packadd lualine.nvim ]]

-- Config for: lualine.nvim
require('plugs.lualine')

vim.cmd [[ packadd bufferline.nvim ]]

-- Config for: bufferline.nvim
require('plugs.bufferline')

vim.cmd [[ packadd zen-mode.nvim ]]
vim.cmd [[ packadd twilight.nvim ]]

-- Config for: twilight.nvim
require('plugs.twilight')

vim.cmd [[ packadd popup.nvim ]]
vim.cmd [[ packadd vista.vim ]]

-- Config for: vista.vim
require('plugs.vista')

vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
require('plugs.telescope')

vim.cmd [[ packadd telescope-frecency.nvim ]]

-- Config for: telescope-frecency.nvim
require("telescope").load_extension("frecency")

vim.cmd [[ packadd nvim-dap ]]

-- Config for: nvim-dap
require('plugs.dap').config()

vim.cmd [[ packadd nvim-dap-python ]]

-- Config for: nvim-dap-python
try_loadstring("\27LJ\2\nv\0\0\6\0\a\0\f6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0\18\4\2\0009\2\4\0026\5\5\0009\5\6\5B\2\3\0A\0\0\1K\0\1\0\15PYENV_ROOT\benv\vformat\20%s/shims/python\nsetup\15dap-python\frequire\0", "config", "nvim-dap-python")

vim.cmd [[ packadd nvim-dap-ui ]]

-- Config for: nvim-dap-ui
try_loadstring("\27LJ\2\n3\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\ndapui\frequire\0", "config", "nvim-dap-ui")

vim.cmd [[ packadd telescope-dap.nvim ]]

-- Config for: telescope-dap.nvim
require("telescope").load_extension("dap")

vim.cmd [[ packadd urlview.nvim ]]

-- Config for: urlview.nvim
require('plugs.config').urlview()

vim.cmd [[ packadd telescope-rualdi.nvim ]]

-- Config for: telescope-rualdi.nvim
require("telescope").load_extension("rualdi")

vim.cmd [[ packadd telescope-file-browser.nvim ]]

-- Config for: telescope-file-browser.nvim
require("telescope").load_extension("file_browser")

vim.cmd [[ packadd telescope-coc.nvim ]]

-- Config for: telescope-coc.nvim
require("telescope").load_extension("coc")

vim.cmd [[ packadd telescope-github.nvim ]]

-- Config for: telescope-github.nvim
require("telescope").load_extension("gh")

vim.cmd [[ packadd telescope-ultisnips.nvim ]]

-- Config for: telescope-ultisnips.nvim
require("telescope").load_extension("ultisnips")

vim.cmd [[ packadd telescope-ghq.nvim ]]

-- Config for: telescope-ghq.nvim
require("telescope").load_extension("ghq")

vim.cmd [[ packadd telescope-fzf-native.nvim ]]

-- Config for: telescope-fzf-native.nvim
require("telescope").load_extension("fzf")

vim.cmd [[ packadd telescope-bookmarks.nvim ]]

-- Config for: telescope-bookmarks.nvim
require("telescope").load_extension("bookmarks")

vim.cmd [[ packadd telescope-heading.nvim ]]

-- Config for: telescope-heading.nvim
require("telescope").load_extension("heading")

vim.cmd [[ packadd telescope-hop.nvim ]]

-- Config for: telescope-hop.nvim
require("telescope").load_extension("hop")

vim.cmd [[ packadd telescope-packer.nvim ]]

-- Config for: telescope-packer.nvim
try_loadstring("\27LJ\2\nù\1\0\1\4\0\b\0\0196\1\0\0009\1\1\1'\3\2\0B\1\2\0016\1\3\0'\3\4\0B\1\2\0029\1\5\1'\3\6\0B\1\2\0016\1\3\0'\3\4\0B\1\2\0029\1\a\0019\1\6\0019\1\6\1\18\3\0\0B\1\2\1K\0\1\0\15extensions\vpacker\19load_extension\14telescope\frequire\16packer.nvim\fpackadd\aexA\1\0\3\0\4\0\0066\0\0\0'\2\1\0B\0\2\0023\1\3\0=\1\2\0K\0\1\0\0\vpacker\22telescope.builtin\frequire\0", "config", "telescope-packer.nvim")

vim.cmd [[ packadd telescope-ui-select.nvim ]]

-- Config for: telescope-ui-select.nvim
require("telescope").load_extension("ui-select")

vim.cmd [[ packadd telescope-zoxide ]]

-- Config for: telescope-zoxide
require("telescope").load_extension("zoxide")

vim.cmd [[ packadd coc-fzf ]]
vim.cmd [[ packadd coc-kvs ]]
vim.cmd [[ packadd sqlite.lua ]]
vim.cmd [[ packadd telescope-smart-history.nvim ]]

-- Config for: telescope-smart-history.nvim
require("telescope").load_extension("smart_history")

vim.cmd [[ packadd nvim-treesitter ]]
vim.cmd [[ packadd iswap.nvim ]]
vim.cmd [[ packadd Comment.nvim ]]

-- Config for: Comment.nvim
require('plugs.comment')

vim.cmd [[ packadd nvim-regexplainer ]]

-- Config for: nvim-regexplainer
require('plugs.config').regexplainer()

vim.cmd [[ packadd playground ]]
vim.cmd [[ packadd vim-indent-object ]]
vim.cmd [[ packadd nvim-treesitter-refactor ]]
vim.cmd [[ packadd nvim-tree-docs ]]
vim.cmd [[ packadd nvim-gps ]]

-- Config for: nvim-gps
require("nvim-gps").setup()

vim.cmd [[ packadd nvim-treesitter-textobjects ]]
vim.cmd [[ packadd nvim-ts-context-commentstring ]]
vim.cmd [[ packadd aerial.nvim ]]
vim.cmd [[ packadd nvim_context_vt ]]
vim.cmd [[ packadd nvim-ts-autotag ]]
vim.cmd [[ packadd nvim-treesitter-endwise ]]
vim.cmd [[ packadd spellsitter.nvim ]]

-- Config for: spellsitter.nvim
require("spellsitter").setup()

vim.cmd [[ packadd hlargs.nvim ]]
vim.cmd [[ packadd treesitter-unit ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Glcd lua require("packer.load")({'vim-fugitive'}, { cmd = "Glcd", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Glgrep lua require("packer.load")({'vim-fugitive'}, { cmd = "Glgrep", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndoTreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndoTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GMove lua require("packer.load")({'vim-fugitive'}, { cmd = "GMove", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gpedit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gpedit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gread lua require("packer.load")({'vim-fugitive'}, { cmd = "Gread", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GRemove lua require("packer.load")({'vim-fugitive'}, { cmd = "GRemove", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GRename lua require("packer.load")({'vim-fugitive'}, { cmd = "GRename", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gsplit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gtabedit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gtabedit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GUnlink lua require("packer.load")({'vim-fugitive'}, { cmd = "GUnlink", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gvdiffsplit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gvdiffsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gvsplit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gvsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gwq lua require("packer.load")({'vim-fugitive'}, { cmd = "Gwq", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gwrite lua require("packer.load")({'vim-fugitive'}, { cmd = "Gwrite", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Flog lua require("packer.load")({'vim-flog'}, { cmd = "Flog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Flogsplit lua require("packer.load")({'vim-flog'}, { cmd = "Flogsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file T lua require("packer.load")({'toggleterm.nvim'}, { cmd = "T", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TE lua require("packer.load")({'toggleterm.nvim'}, { cmd = "TE", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file ColorizerToggle lua require("packer.load")({'nvim-colorizer.lua'}, { cmd = "ColorizerToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Grepper lua require("packer.load")({'vim-grepper'}, { cmd = "Grepper", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFileHistory lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFileHistory", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gedit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gedit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file S lua require("packer.load")({'vim-abolish'}, { cmd = "S", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Luapad lua require("packer.load")({'nvim-luapad'}, { cmd = "Luapad", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SudaWrite lua require("packer.load")({'suda.vim'}, { cmd = "SudaWrite", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SudaRead lua require("packer.load")({'suda.vim'}, { cmd = "SudaRead", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file LuaRun lua require("packer.load")({'nvim-luapad'}, { cmd = "LuaRun", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bufferize lua require("packer.load")({'bufferize.vim'}, { cmd = "Bufferize", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewToggleFiles lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewToggleFiles", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file AnyFoldActivate lua require("packer.load")({'vim-anyfold'}, { cmd = "AnyFoldActivate", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewRefresh lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewLog lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewLog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFocusFiles lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFocusFiles", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Subvert lua require("packer.load")({'vim-abolish'}, { cmd = "Subvert", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Abolish lua require("packer.load")({'vim-abolish'}, { cmd = "Abolish", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Ghdiffsplit lua require("packer.load")({'vim-fugitive'}, { cmd = "Ghdiffsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file G lua require("packer.load")({'vim-fugitive'}, { cmd = "G", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gllog lua require("packer.load")({'vim-fugitive'}, { cmd = "Gllog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file 0Git lua require("packer.load")({'vim-fugitive'}, { cmd = "0Git", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GBrowse lua require("packer.load")({'vim-fugitive'}, { cmd = "GBrowse", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gcd lua require("packer.load")({'vim-fugitive'}, { cmd = "Gcd", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gclog lua require("packer.load")({'vim-fugitive'}, { cmd = "Gclog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GDelete lua require("packer.load")({'vim-fugitive'}, { cmd = "GDelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Gdiffsplit lua require("packer.load")({'vim-fugitive'}, { cmd = "Gdiffsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Ggrep lua require("packer.load")({'vim-fugitive'}, { cmd = "Ggrep", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewClose lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewClose", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Git lua require("packer.load")({'vim-fugitive'}, { cmd = "Git", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

-- Keymap lazy-loads
time([[Defining lazy-load keymaps]], true)
vim.cmd [[xnoremap <silent> g# <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g#", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>h <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>h", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> N <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "N", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> gs <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> sS <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sS", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[noremap <silent> <C-\> <cmd>lua require("packer.load")({'toggleterm.nvim'}, { keys = "<lt>C-\\>", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>k <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>k", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> s <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "s", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[vnoremap <silent> g_ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "g_", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[onoremap <silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>dg <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dg", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>gl <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gl", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> se <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "se", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>J <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>J", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>g; <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>g;", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <M--> <cmd>lua require("packer.load")({'nvim-window'}, { keys = "<lt>M-->", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> _ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "_", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>dc <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dc", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>sr <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "<lt>Leader>sr", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>rg <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "<lt>Leader>rg", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> n <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "n", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>/ <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>/", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[vnoremap <silent> _ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "_", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[onoremap <silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> s <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "s", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[onoremap <silent> n <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "n", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[onoremap <silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> gs <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>j <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>j", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> N <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "N", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> <Leader>gL <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>gL", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> ss <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "ss", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>gL <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>gL", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>gO <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>gO", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> cr <cmd>lua require("packer.load")({'vim-abolish'}, { keys = "cr", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>l <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>l", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[noremap <silent> gx <cmd>lua require("packer.load")({'toggleterm.nvim'}, { keys = "gx", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[noremap <silent> gxx <cmd>lua require("packer.load")({'toggleterm.nvim'}, { keys = "gxx", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>yr <cmd>lua require("packer.load")({'vCoolor.vim'}, { keys = "<lt>Leader>yr", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> X <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "X", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> * <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "*", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> + <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "+", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> sxc <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sxc", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>df <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>df", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>gf <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gf", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> sr <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sr", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> ? <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "?", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> * <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "*", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[onoremap <silent> N <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "N", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader><Leader>K <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>K", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> sxx <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sxx", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> # <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "#", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> / <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "/", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> g* <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g*", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> g* <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g*", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[vnoremap <silent> + <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "+", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> g# <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g#", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>pc <cmd>lua require("packer.load")({'vCoolor.vim'}, { keys = "<lt>Leader>pc", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>yb <cmd>lua require("packer.load")({'vCoolor.vim'}, { keys = "<lt>Leader>yb", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> sx <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sx", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> # <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "#", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[onoremap <silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> n <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "n", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[vnoremap <silent> g+ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "g+", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>W <cmd>lua require("packer.load")({'suda.vim'}, { keys = "<lt>Leader>W", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> gJ <cmd>lua require("packer.load")({'nvim-trevJ.lua'}, { keys = "gJ", prefix = "" }, _G.packer_plugins)<cr>]]
time([[Defining lazy-load keymaps]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType vimwiki ++once lua require("packer.load")({'vim-pandoc-syntax', 'vim-markdown', 'vim-table-mode', 'mkdx'}, { ft = "vimwiki" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
vim.cmd [[au FileType gitconfig ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "gitconfig" }, _G.packer_plugins)]]
vim.cmd [[au FileType javascript ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "javascript" }, _G.packer_plugins)]]
vim.cmd [[au FileType typescript ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "typescript" }, _G.packer_plugins)]]
vim.cmd [[au FileType ron ++once lua require("packer.load")({'ron.vim'}, { ft = "ron" }, _G.packer_plugins)]]
vim.cmd [[au FileType zsh ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "zsh" }, _G.packer_plugins)]]
vim.cmd [[au FileType css ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "css" }, _G.packer_plugins)]]
vim.cmd [[au FileType vim ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "vim" }, _G.packer_plugins)]]
vim.cmd [[au FileType perl ++once lua require("packer.load")({'vim-perl'}, { ft = "perl" }, _G.packer_plugins)]]
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust.vim'}, { ft = "rust" }, _G.packer_plugins)]]
vim.cmd [[au FileType tmux ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "tmux" }, _G.packer_plugins)]]
vim.cmd [[au FileType rustpeg ++once lua require("packer.load")({'vim-rustpeg'}, { ft = "rustpeg" }, _G.packer_plugins)]]
vim.cmd [[au FileType python ++once lua require("packer.load")({'vim-slime'}, { ft = "python" }, _G.packer_plugins)]]
vim.cmd [[au FileType just ++once lua require("packer.load")({'vim-just'}, { ft = "just" }, _G.packer_plugins)]]
vim.cmd [[au FileType lf ++once lua require("packer.load")({'lf-vim'}, { ft = "lf" }, _G.packer_plugins)]]
vim.cmd [[au FileType lua ++once lua require("packer.load")({'nvim-luaref', 'nvim-luapad', 'nvim-colorizer.lua', 'nlua.nvim', 'lua-dev.nvim', 'luv-vimdocs'}, { ft = "lua" }, _G.packer_plugins)]]
vim.cmd [[au FileType pandoc ++once lua require("packer.load")({'vim-pandoc-syntax'}, { ft = "pandoc" }, _G.packer_plugins)]]
vim.cmd [[au FileType yaml ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "yaml" }, _G.packer_plugins)]]
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
vim.cmd [[au FileType sh ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "sh" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'vim-pandoc-syntax', 'vim-markdown', 'vim-table-mode', 'nvim-colorizer.lua', 'mkdx'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType xml ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "xml" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'HighStr.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-autopairs'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'persistence.nvim'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre */.git/index ++once lua require("packer.load")({'vim-fugitive'}, { event = "BufReadPre */.git/index" }, _G.packer_plugins)]]
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'dressing.nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead Cargo.toml ++once lua require("packer.load")({'crates.nvim'}, { event = "BufRead Cargo.toml" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
  -- Function lazy-loads
time([[Defining lazy-load function autocommands]], true)
vim.cmd[[au FuncUndefined fugitive#* ++once lua require("packer.load")({'vim-fugitive'}, {}, _G.packer_plugins)]]
time([[Defining lazy-load function autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
